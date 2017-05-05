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

        public abstract void add_network_route (string network_address, string gateway_address, string device_name) throws ConnectionException, IOError;
        public abstract void replace_default_route (string device_name) throws ConnectionException, IOError;
        public abstract void pon (string provider) throws ConnectionException, FileException, IOError;
        public abstract void poff (string provider) throws ConnectionException, FileException, IOError;
        public abstract void create_provider (string provider_name, string network_interface, string username) throws FileException, IOError;
        public abstract void create_secrets (string username, string password) throws FileException, IOError;
    }

    public class Connection : GLib.Object {

        private PPPoEDI.User user;
        private string provider;

        Connection (PPPoEDI.User user, string provider) {
            this.user = user;
            this.provider = provider;
        }

        public void start() throws ConnectionException {
            string route_tool = GLib.Environment.find_program_in_path ("ip") + " " + "route";

            string route_cmd = route_tool + " " + "show" + " " + "default 0.0.0.0/0";
            string route_cmd_stdout;
            string route_cmd_stderr;
            int route_cmd_status;

            try {
                GLib.Process.spawn_command_line_sync (route_cmd,
                                                      out route_cmd_stdout,
                                                      out route_cmd_stderr,
                                                      out route_cmd_status);
            } catch (SpawnError e) {
                warning ("%s", e.message);
            }

            string[] route_tokens = route_cmd_stdout.split (" ");
            string default_gateway = null;
            string default_interface = null;

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

            PPPoEDI.Service service_bus = null;

            try {
                service_bus = GLib.Bus.get_proxy_sync (BusType.SESSION,
                                                  "br.inf.ufes.lar.pppoedi.Service",
                                                  "/br/inf/ufes/lar/pppoedi/service");

                // Add all networks from Settings
                foreach (string network in PPPoEDI.Settings.networks) {
                    service_bus.add_network_route (network, default_gateway, default_interface);
                }

                // Replace the default network
                service_bus.replace_default_route (default_interface);

                // Create the provider configuration file
                service_bus.create_provider (PPPoEDI.Settings.provider_name, default_interface, this.user.username);

                // Create Secrets file
                service_bus.create_secrets (this.user.username, this.user.password);

                // Call the provider and start the PPPoE connection
                service_bus.pon (PPPoEDI.Settings.provider_name);
            }
            catch (Error e) {
                warning ("%s", e.message);
                throw e;
            }
        }

        public void stop() throws ConnectionException {
            PPPoEDI.Service service_bus = null;

            try {
                service_bus = Bus.get_proxy_sync    (BusType.SESSION,
                                                    "br.inf.ufes.lar.pppoedi.Service",
                                                    "/br/inf/ufes/lar/pppoedi/service");

                service_bus.poff (this.provider);
            } catch (Error e) {
                warning ("%s", e.message);
                throw e;
            }
        }
    }
}
