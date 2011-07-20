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
from enigma import ePoint, eTimer
from Components.VariableText import VariableText

class TuxRollName(VariableText, Renderer):

	def __init__(self):
		Renderer.__init__(self)
		VariableText.__init__(self)
		self.ismoveLCD = False
		self.direct = "R"
		self.x = 137
		self.stt = 0
		self.tmp = ""
                     		
	GUI_WIDGET = eLabel

	def connect(self, source):
		Renderer.connect(self, source)
		self.changed((self.CHANGED_DEFAULT,))
		
	def changed(self, what):
		if what[0] == self.CHANGED_CLEAR:
			self.text = ""
		else:
			self.text = (self.source.text).upper()
		if self.instance:
			if len(self.text) > 7:
				self.end = 120 - len(self.text) * 18
				self.x = 10
				self.stt = 0
				if self.ismoveLCD == True:
					self.moveLCD1Text.stop()
				self.instance.move(ePoint(self.x,0))
				self.moveLCD1Text = eTimer()
				self.moveLCD1Text.timeout.get().append(self.moveLCD1TextRun)
				self.moveLCD1Text.start(10000)						
			else:
				if self.ismoveLCD == True:
					self.moveLCD1Text.stop()
					self.instance.move(ePoint(0,0)) 
 
	def moveLCD1TextRun(self):
		self.moveLCD1Text.stop()
		self.ismoveLCD = True
		if self.x != self.end and self.direct == "R":
			self.x = self.x-1       
		elif self.x != 10 and self.direct == "L":
			self.x = self.x+1
		elif self.x == 10:
			self.direct = "R"        
			self.stt =	self.stt + 1
		elif self.x == self.end:
			self.direct = "L"        
			self.stt =	self.stt + 1
		self.instance.move(ePoint(self.x,0))
		if self.stt > 100:
			self.stt = 0		
			self.text = self.text[:7] + ".."
			self.instance.move(ePoint(0,0))
		else:
			self.moveLCD1Text.start(90)       			
