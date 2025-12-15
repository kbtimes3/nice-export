import nice_export

import numpy as np

x = np.linspace(0,10,20)
y = np.exp(-x**2)

print('Started export')
nice_export.do_the_export('out.dat', ['This is the result file', 'This is a second line', 'This is a third line'], ['myx','the_y'], x, y,\
full=False, params={'n':20, 'mode':'ode'})
print('Done.')
