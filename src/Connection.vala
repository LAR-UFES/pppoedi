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
    interface Service : Object {

        public abstract void add_network_route (string network_address, string gateway_address, string device_name) throws ServiceException, IOError;
        public abstract void replace_default_route (string device_name, string gateway_address) throws ServiceException, IOError;
        public abstract void pon (string provider) throws ServiceException, FileException, IOError;
        public abstract void poff (string provider) throws ServiceException, FileException, IOError;
        public abstract void create_provider (string provider_name, string network_interface, string username) throws FileException, IOError;
        public abstract void create_secrets (string username, string password) throws FileException, IOError;
    }

    public class Connection : GLib.Object {

        private PPPoEDI.User user;
        private string provider;

        public Connection (PPPoEDI.User user, string provider) {
            this.user = user;
            this.provider = provider;
        }

        public void start() throws ConnectionException {
            string route_tool = GLib.Environment.find_program_in_path ("ip") + " " + "route";

            string route_cmd = route_tool + " " + "show" + " " + "default 0.0.0.0/0";
            string route_cmd_stdout = null;
            string route_cmd_stderr = null;
            int route_cmd_status;

            try {
                GLib.Process.spawn_command_line_sync (route_cmd,
                                                      out route_cmd_stdout,
                                                      out route_cmd_stderr,
                                                      out route_cmd_status);
            } catch (SpawnError e) {
                warning ("%s", e.message);
            }
            stdout.printf ("%s\n", route_cmd_stdout);
            if ( route_cmd_stdout == "" ) {
                throw new ConnectionException.DEFAULT_ROUTE_NOT_FOUND ("Default route was not found");
            }

            string[] route_tokens = route_cmd_stdout.split (" ");
            string default_gateway = null;
            string default_interface = null;

            // Check if we can find the current system's gateway and
            // the current system's default network interface.
            // Possible Array Format: {"default", "via", `default_gateway`, "dev", `default_interface`}.
            for (int i = 0; i < route_tokens.length; i++) {
                switch (route_tokens[i]) {
                    case "via":
                        default_gateway = route_tokens[i+1];
                        break;
                    case "dev":
                        default_interface = route_tokens[i+1];
                        break;
                }
            }

            // Initialize the service bus as null.
            PPPoEDI.Service service_bus = null;

            try {
                service_bus = GLib.Bus.get_proxy_sync (BusType.SYSTEM,
                                                       "br.inf.ufes.lar.pppoedi.Service",
                                                       "/br/inf/ufes/lar/pppoedi/service");

                // Add all networks from the Constants.
                foreach (string network in PPPoEDI.Constants.NETWORKS) {
                    service_bus.add_network_route (network, default_gateway, default_interface);
                }

                // Create the Provider file.
                service_bus.create_provider (this.provider, default_interface, this.user.username);

                // Create the Secrets file.
                service_bus.create_secrets (this.user.username, this.user.password);

                // Call the provider and start the PPPoE connection
                service_bus.pon (this.provider);

                // Replace the default network
                service_bus.replace_default_route (PPPoEDI.Constants.PPP_INTERFACE, PPPoEDI.Constants.PPP_GATEWAY);
            } catch (Error e) {
                throw e;
            }

            // Create ~/.var directory if it not exists
            try {
                var home_dir = File.new_for_path (Environment.get_home_dir ());
                var default_route_data = home_dir.get_child (".var").get_child ("pppoedi").get_child ("current-interface.data");

                if ( default_route_data.query_exists () ) {
                    default_route_data.delete ();
                }

                if (!default_route_data.get_parent ().query_exists ()) {
                    default_route_data.get_parent ().make_directory_with_parents ();
                }

                var dos = new DataOutputStream (default_route_data.create (FileCreateFlags.REPLACE_DESTINATION));

                dos.put_string (default_interface + ":" + default_gateway);
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        }

        public void stop() throws ConnectionException {

            // Initialize the service bus as null.
            PPPoEDI.Service service_bus = null;

            try {
                service_bus = Bus.get_proxy_sync (BusType.SYSTEM,
                                                  "br.inf.ufes.lar.pppoedi.Service",
                                                  "/br/inf/ufes/lar/pppoedi/service");

                var home_dir = File.new_for_path (Environment.get_home_dir ());
                var default_route_data = home_dir.get_child (".var").get_child ("pppoedi").get_child ("current-interface.data");

                if ( !default_route_data.query_exists () ) {
                    throw new FileException.INTERFACE_DATA_FILE_NOT_FOUND ("Interface data not found");
                }

                var dis = new DataInputStream (default_route_data.read ());
                string line = dis.read_line (null);

                string[] data_array = line.split (":");

                string interface_name = data_array[0];
                string gateway = data_array[1];

                service_bus.poff (this.provider);

                service_bus.replace_default_route (interface_name, gateway);
            } catch (Error e) {
                warning ("%s", e.message);
                throw e;
            }
        }
    }
}
