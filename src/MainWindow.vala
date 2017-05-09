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

    public class MainWindow : Gtk.ApplicationWindow {

        public Gtk.CheckButton  save_username_checkbutton;
        public Gtk.CheckButton  lock_screen_disconnect_checkbutton;
        public Gtk.Entry        username_entry;
        public Gtk.Entry        password_entry;
        public Gtk.Button       connection_button;


        public MainWindow (Gtk.Application application) {
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
            this.username_entry = new Gtk.Entry ();

            // Password entry and entry's placeholder
            var password_label = new Gtk.Label ("Password:");
            password_label.set_xalign (0);
            this.password_entry = new Gtk.Entry ();
            this.password_entry.set_visibility (false);

            // Password saving CheckButton
            this.save_username_checkbutton = new Gtk.CheckButton.with_label ("Save username");

            // Lock screen disconnection CheckButton
            this.lock_screen_disconnect_checkbutton = new Gtk.CheckButton.with_label ("Disconnect on screen locking");

            // Login button
            this.connection_button = new Gtk.Button.with_label ("Connect");

            layout.attach (username_label, 0, 0, 1, 1);
            layout.attach_next_to (this.username_entry, username_label, Gtk.PositionType.BOTTOM, 1, 1);

            layout.attach (password_label, 0, 2, 1, 1);
            layout.attach_next_to (this.password_entry, password_label, Gtk.PositionType.BOTTOM, 1, 1);

            layout.attach (this.save_username_checkbutton, 0, 4, 1, 1);
            //layout.attach (this.lock_screen_disconnect_checkbutton, 0, 5, 1, 1);

            layout.attach (this.connection_button, 0, 6, 1, 1);

            this.add (layout);
        }
    }
}
