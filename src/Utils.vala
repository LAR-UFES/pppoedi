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

namespace PPPoEDI.Utils {
    public void run_route_tool (out string stdin = null, out string stderr = null,
                                out int exit_status = null, string[] args = {}) {

        string cmd = GLib.Environment.find_program_in_path ("ip") + " " + "route" + " ";

        var builder = new StringBuilder ();
        builder.prepend (cmd);

        foreach (string arg in args) {
            builder.append (" ");
            builder.append (arg);
        }

        try {
            GLib.Process.spawn_command_line_sync (builder.str, out stdin, out stderr, out exit_status);
        } catch (SpawnError e) {
            warning ("%s", e.message);
        }
    }
}
