#
#  CaidDisplay - Converter
#
#  Coded by Dr.Best & weazle (c) 2010
#  Support: www.dreambox-tools.info
#
#  This plugin is licensed under the Creative Commons 
#  Attribution-NonCommercial-ShareAlike 3.0 Unported 
#  License. To view a copy of this license, visit
#  http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative
#  Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#
#  Alternatively, this plugin may be distributed and executed on hardware which
#  is licensed by Dream Multimedia GmbH.

#  This plugin is NOT free software. It is open source, you are allowed to
#  modify it (if you keep the license), but it may not be commercially 
#  distributed other than under the conditions noted above.
#  mod by nikolasi
#  later moded by bigroma (13/07/11)

from Components.Converter.Converter import Converter
from enigma import iServiceInformation, iPlayableService
from Components.Element import cached
from Poll import Poll

class CaidDisplay(Poll, Converter, object):
	CAID = 0
	PID = 1
	PROV = 2
	ALL = 3
	IS_NET = 4
	IS_EMU = 5
	CRYPT = 6
	FORMAT = 11

	def __init__(self, type):
		Poll.__init__(self)
		Converter.__init__(self, type)
		if type == "CAID":
			self.type = self.CAID
		elif type == "PID":
			self.type = self.PID
		elif type == "ProvID":
			self.type = self.PROV
		elif type == "Is_Net":
			self.type = self.IS_NET
		elif type == "Is_Emu":
			self.type = self.IS_EMU
		elif type == "CryptInfo":
			self.type = self.CRYPT
		else:
			self.type = self.ALL

		self.systemTxtCaids = {
			"26" : "BiSS",
			"01" : "Seca Mediaguard",
			"06" : "Irdeto",
			"17" : "BetaCrypt",
			"05" : "Viacces",
			"18" : "Nagravision",
			"09" : "NDS Videoguard",
			"0B" : "Conax",
			"0D" : "Cryptoworks",
			"4A" : "DRE-Crypt",
			"0E" : "PowerVu",
			"22" : "Codicrypt",
			"07" : "DigiCipher",
			"56" : "Verimatrix",
			"A1" : "Rosscrypt"}

		self.systemCaids = {
			"26" : "BiSS",
			"01" : "SEC",
			"06" : "IRD",
			"17" : "BET",
			"05" : "VIA",
			"18" : "NAG",
			"09" : "NDS",
			"0B" : "CON",
			"0D" : "CRW",
			"4A" : "DRE" }

		self.poll_interval = 2000
		self.poll_enabled = True

	@cached
	def get_caidlist(self):
		caidlist = {}
		service = self.source.service
		if service:
			info = service and service.info()
			if info:
				caids = info.getInfoObject(iServiceInformation.sCAIDs)
				if caids:
					for cs in self.systemCaids:
						caidlist[cs] = (self.systemCaids.get(cs),0)
					for caid in caids:
						c = ("%0.4X" % int(caid))[:2]
						if self.systemCaids.has_key(c):
							caidlist[c] = (self.systemCaids.get(c),1)
					ecm_info = self.ecmfile()
					if ecm_info:
						emu_caid = ecm_info.get("caid", "")
						if emu_caid and emu_caid != "0x000":
							c = emu_caid.lstrip("0x")
							if len(c) == 3:
								c = "0%s" % c
							c = c[:2].upper()
							caidlist[c] = (self.systemCaids.get(c),2)
		return caidlist

	getCaidlist = property(get_caidlist)

	@cached
	def getBoolean(self):

		service = self.source.service
		info = service and service.info()
		if not info:
			return False
			
		if info.getInfoObject(iServiceInformation.sCAIDs):
			ecm_info = self.ecmfile()
			if ecm_info:
						#oscam
						reader = ecm_info.get("reader", None)
						#cccam	
						using = ecm_info.get("using", "")
						#mgcamd
						source = ecm_info.get("source", None)
						if self.type == self.IS_EMU:
							return using == "emu" or source == "emu" or reader == "emu"
						if self.type == self.IS_NET:
							if using == "CCcam-s2s":
								return 1
							else:
								return  (source != None and source != "emu") or (reader != None and reader != "emu")
						else:
							return False

		return False

	boolean = property(getBoolean)

	@cached
	def getText(self):
		textvalue = "No parse cannot emu"
		service = self.source.service
		if service:
			info = service and service.info()
			if info:
				if info.getInfoObject(iServiceInformation.sCAIDs):
					ecm_info = self.ecmfile()
					if ecm_info:
						# caid
						caid = "%0.4X" % int(ecm_info.get("caid", ""),16)
						if self.type == self.CAID:
							return caid
						# hops
						if self.type == self.CRYPT:
							return "%s" % self.systemTxtCaids.get(caid[:2])
						reader = ecm_info.get("reader", None)
						#pid
						pid = "%0.4X" % int(ecm_info.get("pid", ""),16)
						if self.type == self.PID:
							return pid
						# oscam
						prov = "%0.6X" % int(ecm_info.get("prov", "")[:6],16)
						if self.type == self.PROV:
							return prov
						from2 = "%s" % ecm_info.get("from", None)
						# ecm time	
						ecm_time = ecm_info.get("ecm time", None)
						if ecm_time:
							if "msec" in ecm_time:
								ecm_time = "Ecm: %s " % ecm_time
							else:
								ecm_time = "Ecm: %s s" % ecm_time
						# address
						address = ecm_info.get("address", "")
						#protocol
						protocol = ecm_info.get("protocol", "")
						# source	
						using = ecm_info.get("using", "")
						if using:
							if using == "emu":
								textvalue = "(EMU) Caid: %s - %s" % (caid, ecm_time)
							elif using == "CCcam-s2s":
								textvalue = "(NET) Caid: %s - %s - %s - %s" % (caid, address, reader, ecm_time)
							else:
								textvalue = "%s - %s - Reader: %s - %s" % (caid, address, reader, ecm_time)
						else:
							# mgcamd
							source = ecm_info.get("source", None)
							if source:
								if source == "emu":
									textvalue = "Source:EMU %s" % (caid)
								else:	
									textvalue = "Caid: %s Prov: %s - %s - %s" % (caid, prov, source, ecm_time)
							# oscam
							if reader:
								if reader == "emu":
									textvalue = "Source:EMU %s" % (caid)
								else: 
									textvalue = "Reader: %s ( %s Prov: %s - %s - %s - %s )" % (reader, caid,  prov, from2, ecm_time, protocol)
							# wicardd
							wicarddsource = ecm_info.get("response time", None)
							if wicarddsource:
								textvalue = "%s - Prov: %s - %s" % (caid, prov, wicarddsource)
							# gbox
							decode = ecm_info.get("decode", None)
							if decode:
								if decode == "Internal":
									textvalue = "(EMU) %s" % (caid)
								else:
									textvalue = "%s - %s" % (caid, decode)

		return textvalue 

	text = property(getText)

	def ecmfile(self):
		ecm = None
		info = {}
		service = self.source.service
		if service:
			frontendInfo = service.frontendInfo()
			if frontendInfo:
				try:
					ecmpath = "/tmp/ecm%s.info" % frontendInfo.getAll(False).get("tuner_number")
					ecm = open(ecmpath, "rb").readlines()
				except:
					try:
						ecm = open("/tmp/ecm.info", "rb").readlines()
					except: pass
			if ecm:
				for line in ecm:
					x = line.lower().find("msec")
					if x != -1:
						info["ecm time"] = line[0:x+4]
					else:
						item = line.split(":", 1)
						if len(item) > 1:
							if item[0] == "Provider": 
								item[0] = "prov"#wicard
							info[item[0].strip().lower()] = item[1].strip()
						else:
							if not info.has_key("caid"):
								x = line.lower().find("caid")
								if x != -1:
									y = line.find(",")
									if y != -1:
										info["caid"] = line[x+5:y]
							if not info.has_key("pid"):
								x = line.lower().find("pid")
								if x != -1:
									y = line.find(" =")
									if y != -1:
										info["pid"] = line[x+4:y]

		return info

	def changed(self, what):
		if (what[0] == self.CHANGED_SPECIFIC and what[1] == iPlayableService.evUpdatedInfo) or what[0] == self.CHANGED_POLL:
			Converter.changed(self, what)
