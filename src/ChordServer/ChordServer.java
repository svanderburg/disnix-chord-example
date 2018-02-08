/*
 * ChordServer - non interactively starts a bootstrap Chord node or Chord node
 * joining a bootstrap node
 *
 * Copyright (C) 2018  Sander van der Burg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import de.uniba.wiai.lspi.chord.service.*;
import de.uniba.wiai.lspi.chord.data.*;

public class ChordServer
{
	public static void main(String[] args)
	{
		if(args.length < 2)
		{
			System.err.println("Please provide a hostname/IP address and a port number as parameters!");
			System.err.println("Usage: chord-server hostname port [bootstrap_hostname] [bootstrap_port]");
			System.exit(1);
		}

		de.uniba.wiai.lspi.chord.service.PropertiesLoader.loadPropertyFile();

		String protocol = URL.KNOWN_PROTOCOLS.get(URL.SOCKET_PROTOCOL);
		URL bootstrapURL = null;

		if(args.length >= 3)
		{
			/* If bootstrap parameters have been provided, then configure the bootstrap URL */
			try
			{
				bootstrapURL = new URL(protocol + "://"+args[2]+":"+args[3]+"/");
			}
			catch(java.net.MalformedURLException ex)
			{
				throw new RuntimeException(ex);
			}
		}

		URL localURL = null;

		try
		{
			localURL = new URL(protocol + "://"+args[0]+":"+args[1]+"/");
		}
		catch(java.net.MalformedURLException ex)
		{
			throw new RuntimeException(ex);
		}
		
		Chord chord = new de.uniba.wiai.lspi.chord.service.impl.ChordImpl();

		try
		{
			if(bootstrapURL == null)
				chord.create(localURL); // if no bootstrap parameters are provided, start a new network
			else
				chord.join(localURL, bootstrapURL); // connect to the bootstrap node
		}
		catch(ServiceException ex)
		{
			throw new RuntimeException(ex);
		}
	}
}
