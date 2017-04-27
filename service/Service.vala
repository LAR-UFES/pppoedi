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

    [DBus (name = "br.inf.ufes.lar.pppoedi.Service")]
    public class Service : GLib.Object {

        public void add_network_route (string network_address, string gateway_address, string device_name) throws ConnectionException {
            string cmd = GLib.Environment.find_program_in_path ("ip") + " "
                       + "route" + " "
                       + "add" + " " + network_address + " "
                       + "via" + " " + gateway_address + " "
                       + "dev" + " " + device_name;
            string cmd_stdout;
            string cmd_sterr;
            int cmd_status;

            try {
                GLib.Process.spawn_command_line_sync (cmd,
                                                      out cmd_stdout,
                                                      out cmd_sterr,
                                                      out cmd_status);

            } catch (SpawnError e) {
                throw new ConnectionException.NETWORK_GATEWAY_ADDITION_FAIL ("Failed to execute `ip route add` command");
            }

            if (cmd_status != 0) {
                throw new ConnectionException.NETWORK_GATEWAY_ADDITION_FAIL ("Failed to add network gateway");
            }
        }

        public void add_default_gateway (string device_name) throws ConnectionException {
            string cmd  = GLib.Environment.find_program_in_path ("ip") + " "
                        + "route" + " "
                        + "add" + " " + "default" + " "
                        + "dev" + device_name;
            string cmd_stdout;
            string cmd_sterr;
            int cmd_status;

            try {
                GLib.Process.spawn_command_line_sync (cmd,
                                                      out cmd_stdout,
                                                      out cmd_sterr,
                                                      out cmd_status);
            } catch (SpawnError e) {
                throw new ConnectionException.DEFAULT_GATEWAY_ADDITION_FAIL ("Failed to execute `ip route add default` command");
            }

            if (cmd_status != 0) {
                throw new ConnectionException.DEFAULT_GATEWAY_ADDITION_FAIL ("Failed to add default gateway");
            }
        }

        public void pon (string provider) throws ConnectionException, FileException {
            string provider_file_path = GLib.Path.build_filename ("/", "etc", "ppp", "peers", provider);
            var provider_file = File.new_for_path (provider_file_path);

            string pppd = GLib.Environment.find_program_in_path ("pppd") + " "
                        + "call" + " " + provider;
            string pppd_stdout;
            string pppd_stderr;
            int pppd_status;

            // Test if the provider file really exists
            if (provider_file.query_exists ()) {
                try {
                    // Spawn the `pppd` Process
                    GLib.Process.spawn_command_line_sync (pppd,
                                                         out pppd_stdout,
                                                         out pppd_stderr,
                                                         out pppd_status);
                } catch (SpawnError e) {
                    throw new ConnectionException.PON_FAIL ("Can't spawn `pppd` Process");
                }
            }
            else {
                throw new FileException.PROVIDER_FILE_NOT_FOUND ("Configuration file for provider %s not found", provider);
            }
        }

        public void poff (string provider) throws ConnectionException, FileException {
            string pid_file_path = GLib.Path.build_filename ("/", "var", "run", "ppp0.pid");
            var pid_file = File.new_for_path (pid_file_path);
            Posix.pid_t pppd_pid;

            if (!pid_file.query_exists ()) {
                throw new ConnectionException.POFF_FAIL ("Can't find pppd pid file");
            }

            try {
                var dis = new DataInputStream (pid_file.read ());
                string line = dis.read_line (null);

                pppd_pid = int.parse (line);
            } catch (Error e) {
                error ("%s", e.message);
            }

            // Kill the pid of `pppd call provider` using SIGTERM
            int exit_status = Posix.kill (pppd_pid, 15);

            if (exit_status != 0) {
                throw new ConnectionException.POFF_FAIL ("Can't find pppd pid file");
            }
        }

        public void create_provider (string provider_name, string network_interface, string username) throws FileException {
            string peer_file_path   = GLib.Path.build_filename ("/", "etc", "ppp", "peers", provider_name);
            string peer_config      = "noipdefault\n"
                                    + "defaultroute\n"
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
            string secrets_file_path  = GLib.Path.build_filename ("/", "etc", "ppp", "pap-secrets");

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
