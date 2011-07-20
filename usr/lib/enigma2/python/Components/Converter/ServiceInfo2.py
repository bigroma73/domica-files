# ServiceInfo2 based on standart ServiceInfo from E2
# 
# made by bigroma
# ver 0.2x 11/07/2011
#

from Components.Converter.Converter import Converter
from enigma import iServiceInformation, iPlayableService
from Components.Element import cached

class ServiceInfo2(Converter, object):

	xAPID = 0
	xVPID = 1
	xSID = 2
	sCAIDs = 3

	def __init__(self, type):
		Converter.__init__(self, type)
		self.type, self.interesting_events = {
				"xAPID": (self.xAPID, (iPlayableService.evUpdatedInfo,)),
				"xVPID": (self.xVPID, (iPlayableService.evUpdatedInfo,)),
				"xSID": (self.xSID, (iPlayableService.evUpdatedInfo,)),
				"CAIDs": (self.sCAIDs, (iPlayableService.evUpdatedInfo,)),
			}[type]

	def getServiceInfoString(self, info, what, convert = lambda x: "%d" % x):
		v = info.getInfo(what)
		if v == -1:
			return "N/A"
		if v == -2:
			return info.getInfoString(what)
		# v == -3 now use only for caids
		# i don't know how it work with another parametrs
		# now i made for returning values as hex string separated by space
		# may be better use convert for formating output but it TBA 
		if v == -3:
			t_objs = info.getInfoObject(what)
			if t_objs and (len(t_objs) > 0):
				ret_val=""
				for t_obj in t_objs:
					ret_val += "%.4X " % t_obj
				return ret_val[:-1]
			else:
				return ""
		return convert(v)


	@cached
	def getText(self):
		service = self.source.service
		info = service and service.info()
		if not info:
			return ""

		if self.type == self.xAPID:
			try:
				return "%0.4X" % int(self.getServiceInfoString(info, iServiceInformation.sAudioPID))
			except:
				return "N/A"
		elif self.type == self.xVPID:
			try:
				return "%0.4X" % int(self.getServiceInfoString(info, iServiceInformation.sVideoPID))
			except:
				return "N/A"
		elif self.type == self.xSID:
			try:
				return "%0.4X" % int(self.getServiceInfoString(info, iServiceInformation.sSID))
			except:
				return "N/A"
		elif self.type == self.sCAIDs:
			return self.getServiceInfoString(info, iServiceInformation.sCAIDs)
		return ""

	text = property(getText)


	def changed(self, what):
		if what[0] != self.CHANGED_SPECIFIC or what[1] in self.interesting_events:
			Converter.changed(self, what)
