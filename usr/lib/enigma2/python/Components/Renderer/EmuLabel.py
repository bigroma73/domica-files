
from Components.VariableText import VariableText 
from enigma import eLabel, eTimer 
from Renderer import Renderer 
from Tools.Directories import fileExists 
class EmuLabel(Renderer,
 VariableText):
    __module__ = __name__

    def __init__(self):
        Renderer.__init__(self)
        VariableText.__init__(self)


    GUI_WIDGET = eLabel

    def changed(self, what):
        self.readTimer = eTimer()
        self.readTimer.callback.append(self.CInfo)
        self.readTimer.start(True, 800)



    def CInfo(self):
        res = ''
        if fileExists('/etc/active_emu.list'):
            f = open('/etc/active_emu.list', 'r')
            fline = f.readline()
            f.close()
        res = fline
        self.text = res



