# MASTER-ONLY: DO NOT MODIFY THIS FILE
#
# Copyright (C) Telecom Paris
# Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)
#
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt

dht11_ctrl: sr timer edge counter
dht11_ctrl_sim: utils_pkg dht11 dht11_ctrl
dht11_ctrl_top: dht11_ctrl unisim
