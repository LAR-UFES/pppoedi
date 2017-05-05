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
	public class PPPoEDIApp : Gtk.Application {
		public PPPoEDIApp () {
			Object (application_id: "br.inf.ufes.lar.pppoedi",
							flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate () {
			var window = new PPPoEDI.MainWindow ();
			this.add_window (window);
			window.show_all ();
		}
	}

	public static int main (string[] args) {
		var application = new PPPoEDIApp ();
		return application.run (args);
	}

/*
    [DBus (name = "br.inf.ufes.lar.pppoedi.Service")]
    interface Service : Object {
        public abstract void add_network_route (string network_address, string gateway_address, string device_name) throws ConnectionException, IOError;
        public abstract void add_default_gateway (string device_name) throws ConnectionException, IOError;
        public abstract void pon (string provider) throws ConnectionException, FileException, IOError;
        public abstract void poff (string provider) throws ConnectionException, FileException, IOError;
        public abstract void create_provider (string provider_name, string network_interface, string username) throws FileException, IOError;
        public abstract void create_secrets (string username, string password) throws FileException, IOError;
    }

    public static int main (string[] args) {
        PPPoEDI.Service service_bus = null;

        try {
            service_bus = Bus.get_proxy_sync    (BusType.SYSTEM,
                                                "br.inf.ufes.lar.pppoedi.Service",
                                                "/br/inf/ufes/lar/pppoedi/service");

            // Add a new gateway for the network
            service_bus.add_network_route ("10.9.0.0/24", "10.9.0.1", "enp63s0");
            service_bus.add_network_route ("10.9.10.0/24", "10.9.0.1", "enp63s0");
            service_bus.add_network_route ("200.137.66.0/24", "10.9.0.1", "enp63s0");

            // Create provider file
            service_bus.create_provider ("lar", "enp63s0", "leonardolemos");
            // Create pap-secrets file
            service_bus.create_secrets ("leonardolemos", "th3r0c3123");

            // Finally connects to PPPoE server by pon method
            service_bus.pon ("lar");

            // Add a new default gateway for the network
            service_bus.add_default_gateway ("ppp0");
        }
        catch (Error e) {
            warning ("%s", e.message);
            throw e;
        }
        return 0;
    } */
}
