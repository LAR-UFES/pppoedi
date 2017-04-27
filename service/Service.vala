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
using PPPoEDI.Exceptions;

namespace PPPoEDI {

    [DBus (name = "br.inf.ufes.lar.pppoedi.Service")]
    public class Service : GLib.Object {

        public void add_network_gateway (string network, string gateway) throws ConnectionException {
            string command  = GLib.Environment.find_program_in_path ("route") + " "
                              + "add -net" + " " + network + " "
                              + "gw" + " " + gateway;



            if (Posix.system (command) != 0)
                throw new ConnectionException.NETWORK_GATEWAY_ADDITION_FAIL ("Failed to add network gateway");
        }

        public void add_default_gateway (string network_interface) throws ConnectionException {
            string command  = GLib.Environment.find_program_in_path ("route") + " "
                              + "add default" + " " + network_interface;

            if (Posix.system (command) != 0)
                throw new ConnectionException.DEFAULT_GATEWAY_ADDITION_FAIL ("Failed to add default gateway");
        }

        public void pon (string provider) throws ConnectionException, FileException {
            string provider_file_path = "/etc/ppp/peers/" + provider;
            var provider_file = File.new_for_path (provider_file_path);

            string pppd = GLib.Environment.find_program_in_path ("pppd") + " " + "call" + " " + provider;
            string pppd_stdout;
            string pppd_stderr;
            int pppd_status;

            // Test if the provider file really exists
            if (provider_file.query_exists ()) {
                // Spawn the `pppd` Process
                // It may take a while to get the exit code
                GLib.Process.spawn_command_line_sync (pppd,
                                                     out pppd_stdout,
                                                     out pppd_stderr,
                                                     out pppd_status);
            }
            else {
                throw new FileException.PROVIDER_FILE_NOT_FOUND ("Configuration file for provider %s not found", provider);
            }

            // Test `pppd` exit code
            // See `man pppd`
            if (pppd_status == 0) {
                debug ("pppd connected to the provider %s with success", provider);
                return;
            }
            else if (pppd_status == 19) {
                throw new ConnectionException.PPP_AUTH_FAIL ("Failed to authenticate in the provider %s", provider);
            }
            else {
                throw new ConnectionException.PON_FAIL ("Failed to connect to provider %s, exited with code (%d)", provider, pppd_status);
            }
        }

        public void poff (string provider) throws ConnectionException, FileException {
            string command = GLib.Environment.find_program_in_path ("poff") + " " + provider;

            if (Posix.system (command) != 0)
                throw new ConnectionException.POFF_FAIL ("Failed to disconnect from provider %s", provider);
        }

        public void create_provider (string provider_name, string network_interface, string username) throws FileException {
            string peer_file_path   = "/etc/ppp/peers/" + provider_name;
            string peer_config      = "noipdefault\n"
                                    + "defaultroute\n"
                                    + "replacedefaultroute\n"
                                    + "hide-password\n"
                                    + "noauth\n"
                                    + "persist\n"
                                    + "plugin rp-pppoe.so" + " "
                                    + "so" + " " + network_interface + "\n"
                                    + "user" + " " + username + "\n"
                                    + "usepeerdns";

            try {
                var peer_file   = File.new_for_path (peer_file_path);
                var file_stream = peer_file.create (FileCreateFlags.REPLACE_DESTINATION);

                var dos = new DataOutputStream (file_stream);
                dos.put_string (peer_config);
            } catch (Error e) {
                throw new FileException.WRITE_PROVIDER_FAIL ("Can't write provider file for provider %s", provider_name);
            }
        }

        public void create_secrets (string username, string password) throws FileException {
            // It contains the PPPoE Secrets file entry
            // Format: "username" * "userpassword"
            string user_secrets       = "\"" + username + "\"" + " * " + "\"" + password + "\"";
            string secrets_file_path  = "/etc/ppp/pap-secrets";

            try {
                var secrets_file    = File.new_for_path (secrets_file_path);
                var file_stream     = secrets_file.create (FileCreateFlags.REPLACE_DESTINATION);

                var dos = new DataOutputStream (file_stream);
                dos.put_string (user_secrets);
            } catch (Error e) {
                throw new FileException.WRITE_SECRETS_FAIL ("Can't write secrets file for user %s", username);
            }
        }
    }

    void on_bus_aquired (DBusConnection conn) {
        try {
            conn.register_object ("/br/inf/ufes/lar/pppoedi/service", new PPPoEDI.Service ());
        } catch (IOError e) {
            error ("Could not register service PPPoediService");
        }
    }

    void main () {
        Bus.own_name (BusType.SYSTEM, "br.inf.ufes.lar.pppoedi.Service", BusNameOwnerFlags.NONE,
                     on_bus_aquired,
                     () => {},
                     () => error ("Could not aquire bus name"));

        new MainLoop ().run ();
    }
}
