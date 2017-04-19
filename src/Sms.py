#!/usr/bin/env python3

import os
import json
#~ import re
import subprocess
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
from webbrowser import open_new_tab
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk
from requests_oauthlib import OAuth2Session
from oauthlib.oauth2.rfc6749.errors import TokenExpiredError

parser = argparse.ArgumentParser(
	description='Send sms via KDE Connect with Google Contacts sync and '
	+ 'autocomplete')
parser.add_argument('-d', '--device', help='connected device id')
args = parser.parse_args()

data_dir = os.path.expanduser('~/.local/share/send-sms')


class RequestHandler(BaseHTTPRequestHandler):

	def do_GET(self):

		loopback_response = parse_qs(urlparse(self.path).query)
		keys = ('code', 'state')
		self.send_response(200)
		self.send_header('Content-type', 'text/html')
		self.end_headers()
		if all(True if key in loopback_response else False for key in keys):
			if loopback_response['state'][0] == GoogleContacts.auth_state:
				GoogleContacts.auth_code = loopback_response['code'][0]
				message = 'Authorization succesfull. You can close this window.'
				self.wfile.write(message.encode())
				return
		message = ('Authorization failed. '
			+ 'Please close this window and try again.')
		self.wfile.write(message.encode())
		return


class GoogleContacts(object):

	auth_code = None
	auth_state = None

	def __init__(self):

		self.client_id = ('56930634232-sqama3feqgkq000m73db3mm4s6jch2c2'
			+ '.apps.googleusercontent.com')
		self.client_secret = 'noEVj4Ti5CRiIr_DQRjhxwGz'
		self.auth_base_url = 'https://accounts.google.com/o/oauth2/v2/auth'
		self.token_url = 'https://www.googleapis.com/oauth2/v4/token'
		self.scope = ['https://www.googleapis.com/auth/contacts.readonly']
		self.local_address = ('127.0.0.1', '8000')
		try:
			with open(os.path.join(data_dir, 'token.json')) as fd:
				self.token = json.loads(fd.read())
		except FileNotFoundError:
			self.token = None

	def serve_redirect(self):

		ip, port = self.local_address
		httpd = HTTPServer((ip, int(port)), RequestHandler)
		httpd.handle_request()

	def get_consent(self):

		google = OAuth2Session(
			self.client_id,
			scope=self.scope,
			redirect_uri='http://' + ':'.join(self.local_address))
		auth_url, auth_state = google.authorization_url(
			self.auth_base_url,
			access_type="offline",
			approval_prompt="force")
		GoogleContacts.auth_state = auth_state
		open_new_tab(auth_url)
		self.serve_redirect()

	def save_token(self):

		if self.token:
			if not os.path.isdir(data_dir):
				os.mkdir(data_dir)
			with open(os.path.join(data_dir, 'token.json'), 'w') as fd:
				fd.write(json.dumps(self.token, indent='\t'))

	def get_token(self):

		google = OAuth2Session(
			self.client_id,
			redirect_uri='http://' + ':'.join(self.local_address),
			# I absolutely do not understand why I have to include redirect_uri
			# in this function, as far as I can tell it serves no purpose
			state=GoogleContacts.auth_state)
		self.token = google.fetch_token(
			self.token_url,
			client_secret=self.client_secret,
			code=GoogleContacts.auth_code)
		self.save_token()

	def refresh_token(self):

		google = OAuth2Session(client_id=self.client_id, token=self.token)
		self.token = google.refresh_token(
			self.token_url,
			client_id=self.client_id,
			client_secret=self.client_secret)
		self.save_token()

	def get_contacts(self):

		people_api = 'https://people.googleapis.com/v1/people/me/connections'
		batchget_api = 'https://people.googleapis.com/v1/people:batchGet'
		request_mask = ['person.phoneNumbers', 'person.names']
		raw_contacts = []
		contacts = []
		google = OAuth2Session(client_id=self.client_id, token=self.token)
		if self.token:
			try:
				connections = google.get(people_api).json()['connections']
			except TokenExpiredError:
				self.refresh_token()
				return self.get_contacts()
		else:
			self.get_consent()
			self.get_token()
			return self.get_contacts()
		resource_names = [connection['resourceName']
			for connection in connections]
		resource_chunks = [resource_names[x:x+50]
			for x in range(0, len(resource_names), 50)]
		for chunk in resource_chunks:
			params = {'resourceNames': chunk,
						'requestMask.includeField': request_mask}
			contacts_chunk = google.get(
				batchget_api, params=params).json()['responses']
			raw_contacts += contacts_chunk
		for contact in raw_contacts:
			try:
				for name in contact['person']['names']:
					if name['metadata']['source']['type'] == 'CONTACT':
						display_name = name['displayName']
			except KeyError:
				display_name = ''
			try:
				for phone in contact['person']['phoneNumbers']:
					contacts.append(
						[phone['canonicalForm'], display_name, phone['type']])
			except KeyError:
				pass
		with open(os.path.join(data_dir, 'contacts.json'), 'w') as fd:
			fd.write(json.dumps(contacts, indent='\t', ensure_ascii=False))
		return contacts


class MessageWindow(Gtk.Window):

	def __init__(self):

		Gtk.Window.__init__(self)
		self.set_icon_name('kdeconnect')
		self.set_border_width(6)
		self.set_position(Gtk.WindowPosition.CENTER)
		self.connect('delete-event', Gtk.main_quit)
		hotkeys = Gtk.AccelGroup()
		self.add_accel_group(hotkeys)

		headerbar = Gtk.HeaderBar(spacing=0)
		headerbar.props.title = 'Send SMS'
		self.set_titlebar(headerbar)

		try:
			with open(os.path.join(data_dir, 'contacts.json')) as fd:
				self.contacts = json.loads(fd.read())
		except FileNotFoundError:
			self.contacts = None

		self.suggestion_iters = []
		self.previous_key = ''

		main_box = Gtk.Box(spacing=6, orientation=Gtk.Orientation.VERTICAL)
		self.add(main_box)
		self.phone_no = Gtk.Entry()
		self.phone_no.set_placeholder_text('Phone number')
		if self.contacts:
			self.phone_no.set_completion(self.get_completion())
		self.phone_no.connect('activate', self.select_first)
		self.phone_no.connect('changed', self.enable_send)
		main_box.pack_start(self.phone_no, True, True, 0)
		scrolled_window = Gtk.ScrolledWindow()
		scrolled_window.set_vexpand(True)
		scrolled_window.set_size_request(250, 200)
		main_box.pack_start(scrolled_window, True, True, 0)
		self.body = Gtk.TextView()
		self.body.set_top_margin(6)
		self.body.set_bottom_margin(6)
		self.body.set_left_margin(4)
		self.body.set_right_margin(4)
		self.body.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
		self.body_buffer = self.body.get_buffer()
		self.body_buffer.connect('changed', self.enable_send)
		scrolled_window.add(self.body)

		self.send = Gtk.Button.new_with_label('Send')
		self.send.add_accelerator(
			'clicked',
			hotkeys,
			Gdk.KEY_Return,
			Gdk.ModifierType.CONTROL_MASK,
			Gtk.AccelFlags.VISIBLE)
		self.send.set_sensitive(False)
		style_context = self.send.get_style_context()
		style_context.add_class('suggested-action')
		self.send.connect('clicked', self.send_msg)
		headerbar.pack_end(self.send)
		sync = Gtk.Button.new_from_icon_name('emblem-synchronizing', 3)
		sync.connect('clicked', self.sync)
		headerbar.pack_end(sync)
		cancel = Gtk.Button.new_with_label('Cancel')
		cancel.connect('clicked', self.cancel)
		headerbar.pack_start(cancel)

		self.show_all()
		self.phone_no.grab_focus()
		Gtk.main()

	def cancel(self, widget):

		self.close()

	def get_completion(self):

		model = Gtk.ListStore(str, str, str)
		for contact in self.contacts:
			model.append((contact[0], ' '.join(contact), contact[1]))
		model.set_sort_column_id(2, Gtk.SortType.ASCENDING)
		completer = Gtk.EntryCompletion()
		completer.set_model(model)
		completer.set_text_column(1)
		completer.set_match_func(self.match_contact, None)
		completer.connect('match-selected', self.select_number)
		return completer

	def match_contact(self, completion, key, tree_iter, udata):

		model = completion.get_model()
		matches = (any(token.startswith(key)
			for token in model[tree_iter][1].casefold().split())
				for key in key.split())
		result = all(matches)
		if key != self.previous_key:
			self.suggestion_iters = []
		if result:
			self.suggestion_iters.append(tree_iter)
		self.previous_key = key
		return result

	def select_number(self, completion, model, tree_iter):

		self.phone_no.set_text(model[tree_iter][0])
		self.body.grab_focus()
		return True

	def select_first(self, entry):

		completion = entry.get_completion()
		if completion and self.suggestion_iters:
			model = completion.get_model()
			tree_iter = self.suggestion_iters[0]
			entry.set_text(model[tree_iter][0])
		self.body.grab_focus()

	def sync(self, widget):

		google_contacts = GoogleContacts()
		self.contacts = google_contacts.get_contacts()
		self.phone_no.set_completion(self.get_completion())

	def enable_send(self, obj):

		phone_no = self.phone_no.get_text()
		start, end = self.body_buffer.get_bounds()
		body = self.body_buffer.get_text(start, end, False)
		if phone_no and body:
			self.send.set_sensitive(True)
		else:
			self.send.set_sensitive(False)

	def send_msg(self, widget):

		phone = self.phone_no.get_text()
		text_buffer = self.body.get_buffer()
		start, end = text_buffer.get_bounds()
		message = text_buffer.get_text(start, end, False)
		subprocess.call([
			'kdeconnect-cli',
			'--device', args.device,
			'--destination', phone,
			'--send-sms', message])
		self.close()

MessageWindow()
