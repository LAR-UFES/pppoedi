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
            PPPoEDI.User user = null;
            PPPoEDI.Connection connection = null;
            var settings = new GLib.Settings ("br.inf.ufes.lar.pppoedi");
            bool is_connected = false;
            var app_window = new PPPoEDI.MainWindow (this);

            this.add_window (app_window);
            app_window.show_all ();

            string? username = settings.get_string ("username");
            if (username != null) { app_window.username_entry.set_text (username); }

            bool save_username = settings.get_boolean ("is-username-saved");
            if (save_username) { app_window.save_username_checkbutton.set_active (true); }

            bool autodisconnect = settings.get_boolean ("auto-disconnect");
            if (autodisconnect) { app_window.lock_screen_disconnect_checkbutton.set_active (true); }

            app_window.connection_button.clicked.connect (() => {

                if (is_connected) {

                    try {
                        connection.stop ();
                        yield;
                        send_offline_notification (this);
                    } catch (Error e) {
                        stdout.printf ("%s", e.message);
                    }

                    is_connected = false;
                    app_window.connection_button.label = "Connect";
                } else {

                    app_window.connection_button.set_sensitive (false);
                    app_window.connection_button.label = "Connecting...";

                    user = new PPPoEDI.User (app_window.username_entry.get_text (), app_window.password_entry.get_text ());
                    connection = new PPPoEDI.Connection (user, PPPoEDI.Constants.PROVIDER_NAME);

                    if (is_connected == false) {

                        // Check if the user checked the 'Save username' option
                        // Then save the username in the Settings
                        if (app_window.save_username_checkbutton.active) {
                            settings.set_string ("username", app_window.username_entry.get_text ());
                        } else {
                            settings.set_string ("username", "");
                        }

                        try {
                            connection.start ();
                            yield;

                            connection.connected.connect (() => {
                                send_online_notification (this);
                                is_connected = true;
                                app_window.connection_button.set_sensitive (true);
                                app_window.connection_button.label = "Disconnect";
                            });


                        } catch (Error e) {
                            stdout.printf ("%s", e.message);
                        }


                    }
                }
            });

            app_window.save_username_checkbutton.toggled.connect (() => {
                if (settings.get_boolean ("is-username-saved")) {
                    settings.set_boolean ("is-username-saved", false);
                } else {
                    settings.set_boolean ("is-username-saved", true);
                }
            });

            app_window.destroy.connect (() => {
                if (app_window != null) {
                    if (is_connected == true) {
                        try {
                            connection.stop ();
                            yield;
                        } catch (Error e) {
                            stdout.printf ("%s", e.message);
                        }
                    }
                }
            });
        }
    }

    private void send_online_notification (Gtk.Application app) {
        var notification = new Notification ("You are online");
        notification.set_body ("You are connected through PPPoEDI");

        var image = new Gtk.Image.from_icon_name ("network-transmit-receive", Gtk.IconSize.DIALOG);
        notification.set_icon (image.gicon);

        app.send_notification ("br.inf.ufes.lar.pppoedi", notification);
    }

    private void send_offline_notification (Gtk.Application app) {
        var notification = new Notification ("You are offline");
        notification.set_body ("You are disconnected from PPPoEDI");

        var image = new Gtk.Image.from_icon_name ("network-offline", Gtk.IconSize.DIALOG);
        notification.set_icon (image.gicon);

        app.send_notification ("br.inf.ufes.lar.pppoedi", notification);
    }

    public static int main (string[] args) {
        var application = new PPPoEDIApp ();
        return application.run (args);
    }
}
