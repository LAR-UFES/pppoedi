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
}
