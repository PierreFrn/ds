#
# Copyright (C) Telecom Paris
# Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

array set ios {
	clk    { L16 LVCMOS33 }
	areset { R18 LVCMOS33 }
    data   { V12 LVCMOS33 }
    sw[0]  { G15 LVCMOS33 }
    sw[1]  { P15 LVCMOS33 }
	led[0] { M14 LVCMOS33 }
	led[1] { M15 LVCMOS33 }
	led[2] { G14 LVCMOS33 }
	led[3] { D18 LVCMOS33 }
}

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
