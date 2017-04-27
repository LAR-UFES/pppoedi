/* Copyright 2016 Laboratório de Administração de Redes (LAR)
*
* This file is part of PPPoEDI.
*
* Hello Again is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Hello Again is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Hello Again. If not, see http://www.gnu.org/licenses/.
*/

namespace PPPoEDI {

    public class MainWindow : Gtk.Window {

        public MainWindow () {
            this.title = "PPPoEDI";
            this.set_border_width (20);
            this.set_position (Gtk.WindowPosition.CENTER);
            this.set_resizable (false);
            this.set_default_size (600, 600);
            this.destroy.connect (Gtk.main_quit);

            try {
                this.icon = Gtk.IconTheme.get_default ().load_icon ("applications-internet", 64, 0);
            } catch (Error e) {
                warning ("Could not load application icon: %s\n", e.message);
            }

            // Create and setup Grid Layout
            var layout = new Gtk.Grid ();
            layout.row_spacing = 12;

            // Username entry and entry's placeholder
            var username_label = new Gtk.Label ("Username:");
            username_label.set_xalign (0);
            var username_entry = new Gtk.Entry ();

            // Password entry and entry's placeholder
            var password_label = new Gtk.Label ("Password:");
            password_label.set_xalign (0);
            var password_entry = new Gtk.Entry ();
            password_entry.set_visibility (false);

            // Password saving CheckButton
            var save_password_checkbutton = new Gtk.CheckButton.with_label ("Save password");

            // Lock screen disconnection CheckButton
            var lock_screen_disconnect_checkbutton = new Gtk.CheckButton.with_label ("Disconnect on screen locking");

            // Login button
            var connection_button = new Gtk.Button.with_label ("Connect");

            layout.attach (username_label, 0, 0, 1, 1);
            layout.attach_next_to (username_entry, username_label, Gtk.PositionType.BOTTOM, 1, 1);

            layout.attach (password_label, 0, 2, 1, 1);
            layout.attach_next_to (password_entry, password_label, Gtk.PositionType.BOTTOM, 1, 1);

            layout.attach (save_password_checkbutton, 0, 4, 1, 1);
            layout.attach (lock_screen_disconnect_checkbutton, 0, 5, 1, 1);

            layout.attach (connection_button, 0, 6, 1, 1);

            this.add (layout);

            connection_button.clicked.connect (() => {
            });
		}
	}
}
