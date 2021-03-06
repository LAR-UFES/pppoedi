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

namespace PPPoEDI.Exceptions {

    public errordomain ServiceException {
        NETWORK_GATEWAY_ADDITION_FAIL,
        ADD_NETWORK_ROUTE_FAIL,
        REPLACE_DEFAULT_ROUTE_FAIL,
        ADD_NEW_DEFAULT_ROUTE_FAIL,
        DEFAULT_ROUTE_REMOVE_FAIL,
        DEFAULT_ROUTE_ADDITION_FAIL,
        PON_FAIL,
        POFF_FAIL,
        PPPOE_CONNECTION_FAIL,
        PPPOE_DISCONNECTION_FAIL,
        PPPOE_INTERFACE_CONFIGURATION_FAIL,
        PPP_AUTH_FAIL
    }
}
