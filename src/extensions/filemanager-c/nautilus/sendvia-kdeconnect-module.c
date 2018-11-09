/* Copyright 2018 KDE Connect Indicator Developers
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

//#include <config.h>
#include <nautilus-extension.h>
//#include <glib/gi18n-lib.h>
#include "sendvia-kdeconnect.h"


void
nautilus_module_initialize (GTypeModule *module)
{
    nautilus_kdecs_load (module);

    // bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
    // bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
}

void
nautilus_module_shutdown (void)
{
}

void
nautilus_module_list_types (const GType **types,
                            int          *num_types)
{
    static GType type_list[1];

    type_list[0] = NAUTILUS_TYPE_KDECS;
    *types = type_list;

    *num_types = 1;
}
