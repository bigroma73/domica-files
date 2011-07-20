#######################################################################
#
#    Renderer for Enigma2
#    Coded by shamann (c)2010
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation; either version 2
#    of the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    
#######################################################################

from Renderer import Renderer
from enigma import eLabel
from Components.VariableText import VariableText
from enigma import eServiceCenter, iServiceInformation, eDVBFrontendParametersSatellite, eDVBFrontendParametersCable

class TuxNextTP(VariableText, Renderer):

	def __init__(self):
		Renderer.__init__(self)
		VariableText.__init__(self)
		
	GUI_WIDGET = eLabel

	def connect(self, source):
		Renderer.connect(self, source)
		self.changed((self.CHANGED_DEFAULT,))
		
	def changed(self, what):
		if self.instance:
			if what[0] == self.CHANGED_CLEAR:
				self.text = "Transporder info not found !"
			else:
				serviceref = self.source.service
				info = eServiceCenter.getInstance().info(serviceref)
				if info and serviceref:
					sname = info.getInfoObject(serviceref, iServiceInformation.sTransponderData)
					fq = pol = fec = sr = orb = ""
					try:
						if sname.has_key("frequency"):
							tmp = int(sname["frequency"])/1000
							fq = str(tmp) + "  "
						if sname.has_key("polarization"):
							try:
								pol = {
									eDVBFrontendParametersSatellite.Polarisation_Horizontal : "H  ",
									eDVBFrontendParametersSatellite.Polarisation_Vertical : "V  ",
									eDVBFrontendParametersSatellite.Polarisation_CircularLeft : "CL  ",
									eDVBFrontendParametersSatellite.Polarisation_CircularRight : "CR  "}[sname["polarization"]]
							except:
								pol = "N/A  "
						if sname.has_key("fec_inner"):
							try:
								fec = {
									eDVBFrontendParametersSatellite.FEC_None : _("None  "),
									eDVBFrontendParametersSatellite.FEC_Auto : _("Auto  "),
									eDVBFrontendParametersSatellite.FEC_1_2 : "1/2  ",
									eDVBFrontendParametersSatellite.FEC_2_3 : "2/3  ",
									eDVBFrontendParametersSatellite.FEC_3_4 : "3/4  ",
									eDVBFrontendParametersSatellite.FEC_5_6 : "5/6  ",
									eDVBFrontendParametersSatellite.FEC_7_8 : "7/8  ",
									eDVBFrontendParametersSatellite.FEC_3_5 : "3/5  ",
									eDVBFrontendParametersSatellite.FEC_4_5 : "4/5  ",
									eDVBFrontendParametersSatellite.FEC_8_9 : "8/9  ",
									eDVBFrontendParametersSatellite.FEC_9_10 : "9/10  "}[sname["fec_inner"]]
							except:
								fec = "N/A  "
							if fec == "N/A  ":
								try:
									fec = {
										eDVBFrontendParametersCable.FEC_None : _("None  "),
										eDVBFrontendParametersCable.FEC_Auto : _("Auto  "),
										eDVBFrontendParametersCable.FEC_1_2 : "1/2  ",
										eDVBFrontendParametersCable.FEC_2_3 : "2/3  ",
										eDVBFrontendParametersCable.FEC_3_4 : "3/4  ",
										eDVBFrontendParametersCable.FEC_5_6 : "5/6  ",
										eDVBFrontendParametersCable.FEC_7_8 : "7/8  ",
										eDVBFrontendParametersCable.FEC_8_9 : "8/9  ",}[sname["fec_inner"]]
								except:
									fec = "N/A  "
						if sname.has_key("symbol_rate"):
							tmp = int(sname["symbol_rate"])/1000
							sr = str(tmp) + "  "
						if sname.has_key("orbital_position"):
							try:	
								orb = {
											3590:'Thor/Intelsat (1.0W)',3560:'Amos (4.0W)',3550:'Atlantic Bird (5.0W)',3530:'Nilesat/Atlantic Bird (7.0W)',
											3520:'Atlantic Bird (8.0W)',3475:'Atlantic Bird (12.5W)',3460:'Express (14.0W)', 3450:'Telstar (15.0W)',
											3420:'Intelsat (18.0W)',3380:'Nss (22.0W)',3355:'Intelsat (24.5W)', 3325:'Intelsat (27.5W)',3300:'Hispasat (30.0W)',
											3285:'Intelsat (31.5W)',3170:'Intelsat (43.0W)',3150:'Intelsat (45.0W)',3070:'Intelsat (53.0W)',3045:'Intelsat (55.5W)',
											3020:'Intelsat 9 (58.0W)',2990:'Amazonas (61.0W)',2900:'Star One (70.0W)',2880:'AMC 6 (72.0W)',2875:'Echostar 6 (72.7W)',
											2860:'Horizons (74.0W)',2810:'AMC5 (79.0W)',2780:'NIMIQ 4 (82.0W)',2690:'NIMIQ 1 (91.0W)',3592:'Thor/Intelsat (0.8W)',
											2985:'Echostar 3,12 (61.5W)',2830:'Echostar 8 (77.0W)',2630:'Galaxy 19 (97.0W)',2500:'Echostar 10,11 (110.0W)',
											2502:'DirectTV 5 (110.0W)',2410:'Echostar 7 Anik F3 (119.0W)',2391:'Galaxy 23 (121.0W)',2390:'Echostar 9 (121.0W)',
											2412:'DirectTV 7S (119.0W)',2310:'Galaxy 27 (129.0W)',2311:'Ciel 2 (129.0W)',2120:'Echostar 2 (148.0W)',
											1100:'BSat 1A,2A (110.0E)',1101:'N-Sat 110 (110.0E)',1131:'KoreaSat 5 (113.0E)',1400:'Express AM3 (140.0E)',
											1006:'AsiaSat 2 (100.5E)',1030:'Express A2 (103.0E)',1056:'Asiasat 3S (105.5E)',1082:'NSS 11 (108.2E)',
											881:'ST1 (88.0E)',900:'Yamal 201 (90.0E)',950:'Insat 4B (95.0E)',951:'NSS 6 (95.0E)',965:'Express AM33 (96.5E)',
											765:'Telestar (76.5E)',785:'ThaiCom 5 (78.5E)',800:'Express AM2/MD1 (80.0E)',830:'Insat 4A (83.0E)',852:'Intelsat 15 (85.2E)',
											750:'ABS 1/1A/Eutelsat W75 (75.0E)',720:'Intelsat (72.0E)',705:'Eutelsat W5 (70.5E)',685:'Intelsat (68.5E)',620:'Intelsat 902 (62.0E)',
											600:'Intelsat 904 (60.0E)',560:'Bonum 1 (56.0E)',530:'Express AM22 (53.0E)',480:'Eutelsat 2F2 (48.0E)',450:'Intelsat (45.0E)',
											420:'Turksat 2A (42.0E)',400:'Express AM1 (40.0E)',390:'Hellas Sat 2 (39.0E)',380:'Paksat 1 (38.0E)',
											360:'Eutelsat W4/W7 (36.0E)',335:'Astra 1M (33.5E)',330:'Eurobird 3 (33.0E)',328:'Galaxy 11 (32.8E)',
											315:'Astra 5A (31.5E)',310:'Turksat (31.0E)',305:'Arabsat (30.5E)',285:'Eurobird 1 (28.5E)',
											284:'Eurobird/Astra (28.2E)',282:'Eurobird/Astra (28.2E)',1220:'AsiaSat (122.0E)',1380:'Telstar 18 (138.0E)',
											260:'Badr 3/4 (26.0E)',255:'Eurobird 2 (25.5E)',232:'Astra 3A/3B (23.5E)',235:'Astra 3A/3B (23.5E)',215:'Eutelsat (21.5E)',
											216:'Eutelsat W6 (21.6E)',210:'AfriStar 1 (21.0E)',192:'Astra 1F (19.2E)',160:'Eutelsat W2 (16.0E)',
											130:'Hot Bird 6/8/9 (13.0E)',100:'Eutelsat W1 (10.0E)',90:'Eurobird 9 (9.0E)',70:'Eutelsat W3A (7.0E)',
											50:'Sirius 4 (5.0E)',48:'Astra 4A (4.8E)',40:'Eurobird 4A (4.0E)',30:'Telecom 2 (3.0E)'
											}[sname["orbital_position"]]
							except:
								orb = "Unknown"
					except:
						pass
					self.text = fq + pol + fec + sr + orb



