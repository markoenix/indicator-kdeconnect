/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

#pragma once

#include <glib-object.h>

G_BEGIN_DECLS

#define NAUTILUS_TYPE_KDECS (nautilus_kdecs_get_type ())

G_DECLARE_FINAL_TYPE (NautilusKdecs, nautilus_kdecs, NAUTILUS, KDECS, GObject)

void nautilus_kdecs_load (GTypeModule *module);

GVariant* get_reachable_devices (NautilusKdecs *kdecs);

static void sendto_callback (NautilusMenuItem *item, gpointer user_data);

static void sendto_proxy (gchar *device, gchar *uri, GDBusProxy *proxy);

static gboolean process_error (GError *error);

//static void sendto_sendvia_kdeconnect ();

G_END_DECLS