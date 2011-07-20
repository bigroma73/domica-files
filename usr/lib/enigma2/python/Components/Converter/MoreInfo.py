from Components.Converter.Converter import Converter
from enigma import iServiceInformation, iFrontendInformation, eDVBFrontendParametersSatellite
from enigma import eServiceCenter, eServiceReference
from Components.Element import cached
from xml.etree.cElementTree import parse
import time

class MoreInfo(Converter, object):
	ALL  = 0
	FREQ = 1
	SR   = 2
	POLAR= 3
	FEC  = 4
	VER  = 5
	SERVNUM = 6
	SATNAME = 7
	SERVREF = 8
	TST = 9

	def __init__(self, type):
		Converter.__init__(self, type)
		self.i = 0
		self.SatLst  = {}		# 1:0:1:300:65:64:3840000:0:0:0: = 5
		self.SatLst2 = {}		# Extreme Sports = 54
		self.SatNameLst = {}	# 750 = ABS 1 (75.0E)
		# numerate tv
		self.getServList(eServiceReference('1:7:1:0:0:0:0:0:0:0:(type == 1) || (type == 17) || (type == 195) || (type == 25) FROM BOUQUET "bouquets.tv" ORDER BY bouquet'))
		# numerate radio
		self.getServList(eServiceReference('1:7:2:0:0:0:0:0:0:0:(type == 2) FROM BOUQUET "bouquets.radio" ORDER BY bouquet'))
		self.CreateSatList() 	# sat name list 
		
		if type == "All":
			self.type = self.ALL
		elif type == "Freq":
			self.type = self.FREQ
		elif type == "SR":
			self.type = self.SR
		elif type == "Polar":
			self.type = self.POLAR
		elif type == "FEC":
			self.type = self.FEC
		elif type == "Ver":
			self.type = self.VER
		elif type == "ServNum":
			self.type = self.SERVNUM
		elif type == "SatName":
			self.type = self.SATNAME
		elif type == "ServRef":
			self.type = self.SERVREF
		elif type == "Tst":   # some tests and debug
			self.type = self.TST
#		elif type == "vPID":
#			self.type = self.VPID
#		elif type == "aPID":
#			self.type = self.APID
#		elif type == "SID":
#			self.type = self.SID
		else: self.type = self.ALL

	def getServList(self, eSRef):
		tot_num = 0  		# global ch number 
		hService = eServiceCenter.getInstance()
		Services = hService.list(eSRef)
		Bouquets = Services and Services.getContent("SN", True)
		for bq in Bouquets:
			srv = hService.list(eServiceReference(bq[0]))
			chs = srv and srv.getContent("SN", True)
			for ch in chs:
				if not ch[0].startswith('1:64:'):	# fuck all markers 
					tot_num = tot_num + 1
					self.SatLst[ch[0]] = tot_num	# 1:0:1:300:65:64:3840000:0:0:0: = 5
					self.SatLst[ch[1]] = tot_num	# Extreme Sports = 54
	
	def CreateSatList(self):
		XmlLst = parse("/etc/tuxbox/satellites.xml").getroot()
		if XmlLst != None:
			for s in XmlLst.findall("sat"):
				sname = s.get("name")
				spos  = s.get("position")
				self.SatNameLst[spos] = sname		# '750' = 'ABS 1 (75.0E)'

	@cached
	def getText(self):
		# ---------------------- ver
		if self.type == self.VER:
			return self.VERSION
		service = self.source.service
		info = service and service.info()
		if not info:
			return "No service.info() (MoreInfo error)"
		tpi = info.getInfoObject(iServiceInformation.sTransponderData)
		if tpi is not None:
			sr=0
			freq=0
			polar="n/a"
			fec="n/a"
			try:	# real sat/cab/ter service?
				if tpi.has_key("frequency"):
					freq = int(tpi["frequency"])/1000
					if self.type == self.FREQ:
						return str(freq)
			except:
				return "Error! non-sat <info.getInfoObject> service"
			chnl = info.getInfoString(iServiceInformation.sServiceref)
			# ---------------------- Tst
			if self.type == self.TST:
				return "Tst"
			# ---------------------- service ref
			elif self.type == self.SERVREF:
				if len(chnl)>5:
					return str(chnl)
				else: return "n/a"
			# ---------------------- service number
			elif self.type == self.SERVNUM:
				if chnl in self.SatLst: 
					num = self.SatLst[chnl]
					return str(num)
				else:						
					name = info.getName()	#.....or getName(service)
					if name in self.SatLst2: 
						num = self.SatLst2[name]
						return str(num)
				return "00"					# error odnako!
			# ---------------------- sat name
			elif self.type == self.SATNAME:
				try:
					orb = str(tpi["orbital_position"])
				except:
					return "----"
				if orb in self.SatNameLst:
					return self.SatNameLst[orb] 
				if int(orb)>=1800:
					orb = str(int(orb)-3600)
					if orb in self.SatNameLst:
						return self.SatNameLst[orb] 
				return "----"
			# ---------------------- transponder info
			if tpi.has_key("polarization"):
				# GP4.0 :polarization => VERTICAL, HORIZONTAL, CIRCULAR RIGHT, CIRCULAR LEFT
				# GP4.1+:polarization => 0 1 2 3
				polar = str(tpi["polarization"])
				if len(polar) > 1:
					if len(polar) < 11: 
						polar = tpi["polarization"][0]
					else: 	
						polar = tpi["polarization"][9]
				else:
					if polar == "0":
						polar = "H"
					elif polar == "1":
						polar = "V"
					elif polar == "2":
						polar = "CL"
					elif polar == "3":
						polar = "CR"
					else:
						polar ="?"
				if self.type == self.POLAR:
					return str(polar)
			if tpi.has_key("symbol_rate"):
				# GP 4.1+ variant
				sr = int(tpi["symbol_rate"])/1000
				if self.type == self.SR:
					return str(sr)
			elif tpi.has_key("symbolrate"):
				# GP 4.0 variant
				sr = int(tpi["symbolrate"])/1000
				if self.type == self.SR:
					return str(sr)
			if tpi.has_key("fec_inner"):
				# GP 4.1+ variant
				fec = str(tpi["fec_inner"])
				if fec == "0":
					fec = "AUTO"
				elif fec == "1":
					fec = "1/2"
				elif fec == "2":
					fec = "2/3"
				elif fec == "3":
					fec = "3/4"
				elif fec == "4":
					fec = "5/6"
				elif fec == "5":
					fec = "7/8"
				elif fec == "6":
					fec = "8/9"
				elif fec == "7":
					fec = "3/5"
				elif fec == "8":
					fec = "4/5"
				elif fec == "9":
					fec = "9/10"
				elif fec == "15":
					fec = "None"
				else:	
					fec = "?"
				if self.type == self.FEC:
					return str(fec)
			elif tpi.has_key("fec inner"):
				# GP 4.0 variant
				fec = tpi["fec inner"]
				if self.type == self.FEC:
					return str(fec)
			if self.type == self.ALL:
				return "%d %s %d %s" % (freq, polar, sr, fec)
		else: return "sTransponderData is None (MoreInfo error)"
		return "MoreInfo usage error!"
	text = property(getText)


