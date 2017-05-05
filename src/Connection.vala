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
    interface Service : Object {
        public abstract void add_network_gateway (string network, string gateway) throws ConnectionException, IOError;
        public abstract void add_default_gateway (string network_interface) throws ConnectionException, IOError;
        public abstract void pon (string provider) throws ConnectionException, FileException, IOError;
        public abstract void poff (string provider) throws ConnectionException, FileException, IOError;
        public abstract void create_provider (string provider_name, string network_interface, string username) throws FileException, IOError;
        public abstract void create_secrets (string username, string password) throws FileException, IOError;
    }

    public class Connection : Object {

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
            string default_gateway;
            string default_interface;

            for (int i = 0; int < route_tokens.length (); i++) {
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
                service_bus = Bus.get_proxy_sync    (BusType.SESSION,
                                                    "br.inf.ufes.lar.pppoedi.Service",
                                                    "/br/inf/ufes/lar/pppoedi/service");

                // Add a new gateway for the network
                service_bus.add_network_gateway (subnet_gateway, network_interface);
                // Add a new default gateway for the network
                service_bus.add_default_gateway (network_interface);

                // Create provider file
                service_bus.create_provider (this.provider, network_interface, this.user.username);
                // Create pap-secrets file
                service_bus.create_secrets (this.user.username, this.user.password);

                // Finally connects to PPPoE server by pon method
                service_bus.pon (this.provider);
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
