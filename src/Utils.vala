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
    public class Utils : Object {
        public static string command_output (string command) {
            try {
                int exit_code;
                string std_out;
                Process.spawn_command_line_sync (command, out std_out, null, out exit_code);
                return std_out;
            } catch (Error e) {
                error (e.message);
            }
        }

        public static string program_path (string program_path) {
            string whereis_program = Utils.command_output ("whereis -b " + program_path);
            string program_bin_path = whereis_program.splice(0,6);

            return program_bin_path;
        }

        public static string uchar_array_to_string (uchar[] data, int length = -1) {
            if (length < 0)
                length = data.length;

            StringBuilder builder = new StringBuilder ();

            for (int ctr = 0; ctr < length; ctr++) {
                if (data[ctr] != '\0')
                    builder.append_c ((char) data[ctr]);
                else
                    break;
            }

            return builder.str;
        }

        public static uchar[] string_to_uchar_array (string str) {
            uchar[] data = new uchar[0];

            for (int ctr = 0; ctr < str.length; ctr++)
                data += (uchar) str[ctr];

            return data;
        }

        public void serialize (Object obj, string file_path) {
            string data = Json.gobject_to_data (obj, null);

            try {
                var file = File.new_for_path (file_path);

                if (file.query_exists ())
                    file.delete ();

                var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
                dos.put_string (data);
            } catch (Error e) {
                warning ("%s", e.message);
            }
        }
	}
}
