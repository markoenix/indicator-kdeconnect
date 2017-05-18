"""
 Copyright 2017 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.

 This contain parts of functions getted from https://github.com/forabi/nautilus-kdeconnect
"""
#!/usr/bin/env python3

import os
import time
import json
import subprocess
import argparse
import gettext
import locale
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
from webbrowser import open_new_tab
from threading import Thread
from queue import Queue
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Notify', '0.7')
from gi.repository import Gtk, Gdk, Notify
from requests_oauthlib import OAuth2Session
from oauthlib.oauth2.rfc6749.errors import TokenExpiredError

_ = gettext.gettext
locale.setlocale(locale.LC_ALL, '')
gettext.bindtextdomain('indicator-kdeconnect', '/usr/share/locale')
gettext.textdomain('indicator-kdeconnect')

parser = argparse.ArgumentParser(
	description='Send sms via KDE Connect with Google Contacts sync and '
	+ 'autocomplete')
parser.add_argument('-d', '--device', help='connected device id')
args = parser.parse_args()

data_dir = os.path.expanduser('~/.local/share/indicator-kdeconnect/sms')


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
				message = _(
					'Authorization succesfull. You can close this window.')
				self.wfile.write(message.encode())
				return
		message = _('Authorization failed. '
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
		self.local_address = ('127.0.0.1', '8013')
		try:
			with open(os.path.join(data_dir, 'token.json')) as fd:
				self.token = json.loads(fd.read())
		except FileNotFoundError:
			self.token = None
		self.contacts = Queue()
		self.sync = Thread(target=self.get_contacts, name='Sync')

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
				os.makedirs(data_dir, exist_ok=True)
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
		google = OAuth2Session(client_id=self.client_id, token=self.token)

		def get_connections():

			connections = []
			space_requests = True
			params_paging = {'pageSize': 500,
							'pageToken': None}
			response = google.get(people_api, params=params_paging).json()
			try:
				connections += response['connections']
			except KeyError:
				print(response)
			if int(response['totalPeople']) < 200:
				space_requests = False
			while 'nextPageToken' in response:
				if space_requests:
					time.sleep(20)
				params_paging['pageToken'] = response['nextPageToken']
				response = google.get(people_api, params=params_paging).json()
				connections += response['connections']
			return space_requests, connections

		if self.token:
			try:
				space_requests, connections = get_connections()
			except TokenExpiredError:
				self.refresh_token()
				google = OAuth2Session(
					client_id=self.client_id, token=self.token)
				space_requests, connections = get_connections()
		else:
			self.get_consent()
			try:
				self.get_token()
				space_requests, connections = get_connections()
			except ValueError:
				space_requests, connections = (False, [])
		resource_names = [connection['resourceName']
			for connection in connections]
		resource_chunks = [resource_names[x:x+50]
			for x in range(0, len(resource_names), 50)]
		for chunk in resource_chunks:
			contacts_chunk = []
			params_filter = {'resourceNames': chunk,
							'requestMask.includeField': request_mask}
			if space_requests:
				time.sleep(20)
			response = google.get(batchget_api, params=params_filter).json()
			raw_contacts = response['responses']
			for contact in raw_contacts:
				try:
					for name in contact['person']['names']:
						if name['metadata']['source']['type'] == 'CONTACT':
							display_name = name['displayName']
				except KeyError:
					display_name = ''
				try:
					for phone in contact['person']['phoneNumbers']:
						contacts_chunk.append(
							[phone['canonicalForm'],
							display_name,
							phone['type']])
				except KeyError:
					pass
			self.contacts.put_nowait(contacts_chunk)
		self.contacts.put_nowait(None)


class MessageWindow(Gtk.Window):

	def __init__(self):

		Gtk.Window.__init__(self)
		Notify.init('KDE Connect Indicator')
		self.set_icon_name('kdeconnect')
		self.set_border_width(6)
		self.set_position(Gtk.WindowPosition.CENTER)
		self.connect('delete-event', Gtk.main_quit)
		hotkeys = Gtk.AccelGroup()
		self.add_accel_group(hotkeys)

		headerbar = Gtk.HeaderBar(spacing=0)
		headerbar.props.title = _('Compose SMS')
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
		self.phone_no.set_placeholder_text(_('Phone number'))
		self.phone_no.set_completion(self.get_completion())
		self.phone_no.connect('activate', self.select_first)
		self.phone_no.connect('changed', self.on_entry)
		main_box.pack_start(self.phone_no, True, True, 0)
		scrolled_window = Gtk.ScrolledWindow()
		scrolled_window.set_vexpand(True)
		scrolled_window.set_size_request(300, 250)
		main_box.pack_start(scrolled_window, True, True, 0)
		self.body = Gtk.TextView()
		self.body.set_top_margin(6)
		self.body.set_bottom_margin(6)
		self.body.set_left_margin(4)
		self.body.set_right_margin(4)
		self.body.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
		self.body_buffer = self.body.get_buffer()
		self.body_buffer.connect('changed', self.on_entry)
		scrolled_window.add(self.body)
		self.char_count = Gtk.Label('0')
		self.char_count.set_halign(Gtk.Align.END)
		main_box.pack_start(self.char_count, False, False, 0)

		self.send = Gtk.Button.new_with_label(_('Send'))
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
		sync = Gtk.Button.new_from_icon_name('reload', 3)
		sync.connect('clicked', self.sync)
		headerbar.pack_end(sync)
		cancel = Gtk.Button.new_with_label(_('Cancel'))
		cancel.connect('clicked', self.cancel)
		headerbar.pack_start(cancel)

		self.show_all()
		self.phone_no.grab_focus()
		Gtk.main()

	def get_completion(self):

		self.model = Gtk.ListStore(str, str, str)
		self.model.set_sort_column_id(2, Gtk.SortType.ASCENDING)
		if self.contacts:
			for contact in self.contacts:
				self.model.append((contact[0], ' '.join(contact), contact[1]))
		completer = Gtk.EntryCompletion()
		completer.set_model(self.model)
		completer.set_text_column(1)
		completer.set_match_func(self.match_contact, None)
		completer.connect('match-selected', self.select_number)
		return completer

	def sync(self, widget):

		self.model.clear()
		google_contacts = GoogleContacts()
		google_contacts.sync.start()
		contacts_queue = google_contacts.contacts
		sync = Thread(target=self._sync, name='Loader', args=[contacts_queue])
		sync.start()

	def _sync(self, contacts_queue):

		Notify.Notification.new(
			_('Sync starting'), _('Synchronizing contacts'), 'kdeconnect').show()
		contacts = []
		while True:
			contacts_chunk = contacts_queue.get()
			contacts_queue.task_done()
			if contacts_chunk:
				for contact in contacts_chunk:
					contacts.append(contact)
					self.model.append(
						(contact[0], ' '.join(contact), contact[1]))
			else:
				with open(os.path.join(data_dir, 'contacts.json'), 'w') as fd:
					fd.write(json.dumps(contacts, indent='\t'))
				Notify.Notification.new(
					_('Sync done'),
					_('Synchronized contacts'),
					'kdeconnect').show()
				Notify.uninit()
				break

	def cancel(self, widget):

		self.close()

	def match_contact(self, completion, key, tree_iter, udata):

		model = completion.get_model()
		key = self.phone_no.get_text().casefold().split(';')[-1].strip()
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

		entry = completion.get_entry()
		phones = entry.get_text()
		phones_list = phones.split(';')
		phone = model[tree_iter][0]
		entry.set_text(
			'; '.join(phones_list[:-1])
			+ ('; ' if ';' in phones else '')
			+ phone
			+ '; ')
		entry.set_position(-1)
		self.suggestion_iters = []
		return True

	def select_first(self, entry):

		completion = entry.get_completion()
		phones = entry.get_text()
		phones_list = phones.split(';')
		if completion and self.suggestion_iters:
			model = completion.get_model()
			tree_iter = self.suggestion_iters[0]
			phone = model[tree_iter][0]
			entry.set_text(
				'; '.join(phones_list[:-1])
				+ ('; ' if ';' in phones else '')
				+ phone
				+ '; ')
			entry.set_position(-1)
			self.suggestion_iters = []
		else:
			self.body.grab_focus()

	def on_entry(self, obj):

		phone_no = self.phone_no.get_text()
		start, end = self.body_buffer.get_bounds()
		body = self.body_buffer.get_text(start, end, False)
		if phone_no and body:
			self.send.set_sensitive(True)
		else:
			self.send.set_sensitive(False)
		if body:
			char_count = len(body)
			msg_count = char_count // 160 + 1
			string = ('{0} ({1})'.format(char_count, msg_count)
				if msg_count > 1 else str(char_count))
			self.char_count.set_label(string)
		else:
			self.char_count.set_label('0')

	def send_msg(self, widget):

		phones = self.phone_no.get_text().split(';')
		text_buffer = self.body.get_buffer()
		start, end = text_buffer.get_bounds()
		message = text_buffer.get_text(start, end, False)
		#~ chunks = (message[x:x+160] for x in range(0, len(message), 160))
		#~ for chunk in chunks:
		for phone in phones:
			if not phone.isspace():
				subprocess.call([
					'kdeconnect-cli',
					'--device', args.device,
					'--destination', phone.strip(),
					'--send-sms', message])
		self.close()

MessageWindow()
