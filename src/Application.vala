// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2016-2017 Laboratório de Administração de Redes - LAR (https://lar.inf.ufes.br)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Leonardo Lemos <leonardolemos@inf.ufes.br>
 */
using PPPoEDI.Exceptions;

namespace PPPoEDI {

    public class PPPoEDIApp : Gtk.Application {
        public PPPoEDIApp () {
            Object (application_id: "br.inf.ufes.lar.pppoedi",
                flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate () {
            var app_window = new PPPoEDI.MainWindow (this);

            app_window.show_all ();
        }
    }

    public static int main (string[] args) {
        /*var application = new PPPoEDIApp ();
        return application.run (args);*/
    }
}
