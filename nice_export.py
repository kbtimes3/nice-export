import os
import sys
import datetime

__NICE_DIGITS__ = 15

def change_digits(*args):
    """
    Change the number of significant digits for exporting the data.
    This is the variable __NICE_DIGITS__

    Arguments:
    n -- The new number of significant digits
    """
    global __NICE_DIGITS__
    # If there are no arguments or more than one, return to the default value
    if len(args)==0 or len(args)>1:
        __NICE_DIGITS__ = 15
        return
    if len(args)==1:
        __NICE_DIGITS__ = args[0]
        return

def debug_digits():
    print(__NICE_DIGITS__)

def mystr(num):
    """
    Format the input in scientific notation
    """
    the = '{:.'+str(__NICE_DIGITS__)+'e}'
    return the.format(num)

def do_preamble(desc, cols, **kwargs):
    """
    Returns a list of lines to put in the "preamble" of the document (i.e. before the values)

    Arguments:
    desc -- description of the data, as a string or a list of strings
    cols -- headers of the columns, as a list of strings

    Keyword arguments:
    comment -- the character to append in front of lines that do not represent data (default #)
    full -- whether to add the filepath to the name of the script (default True)
    params -- dictionary with the names and values of parameters (default {})
    """
    # Get the comment character
    try:
        separator = kwargs['comment']
    except KeyError:
        separator = '#'
    # Get absolute file path or just script name
    try:
        full_name = kwargs['full']
    except KeyError:
        full_name = True
    if full_name:
        the_script = os.path.join(os.getcwd(), sys.argv[0])
    else:
        the_script = sys.argv[0]
    # Get parameters
    try:
        parameters = kwargs['params']
    except KeyError:
        parameters = {}
    # Get the current time
    # Remove the microsecond information
    right_now = str(datetime.datetime.now())[:-7]
    # Get the Python version
    my_python = str(sys.version_info[0])+'.'+str(sys.version_info[1])+'.'+str(sys.version_info[2])
    # Construct the list to return
    lines = []
    # Add the description
    if type(desc) is str:
        lines.append(separator+' '+desc)
    if type(desc) is list:
        for element in desc:
            lines.append(separator+' '+element)
    # Add the Python version, script name and date
    lines.append(separator+' Data computed using Python version: '+my_python)
    lines.append(separator+' Data computed in: '+the_script)
    lines.append(separator+' Data exported at (YYYY-MM-DD HH:MM:SS): '+right_now)
    # Add the parameters, if any
    if len(parameters)!=0:
        lines.append(separator+' Parameters:')
        for key, value in parameters.items():
            param_desc = ''
            param_desc += separator
            param_desc += ' '+key+': '
            # Don't do the scientific formatting for integers
            if type(value) is int:
                param_desc += str(value)
            elif type(value) is float:
                param_desc += mystr(value)
            # If the parameter is a string (this can happen), add quotation marks
            else:
                param_desc += '\''+value+'\''
            lines.append(param_desc)
    # Format the column headers
    column_headers = separator+' '+cols[0]
    for i in range(len(cols)-1):
        # Compute the offset (in spaces) between each column header
        # BUG: This might not work correctly if the first value is negative (oh well)
        # A (positive) number, once formatted, is __NICE_DIGITS__+6 characters long (first digit+comma+exponent)
        # First the first line ONLY, we have to account for the separator and space, which removes two from the offset
        # There is 1 to add to the offset due the space between the values in the columns
        if i==0:
            offset = __NICE_DIGITS__+5-len(cols[i])
        else:
            offset = __NICE_DIGITS__+7-len(cols[i])
        column_headers += ' '*offset+cols[i+1]
    lines.append(column_headers)
    return lines

def do_the_export(filename, desc, cols, *data, **kwargs):
    """
    Export the data to a file, write a preamble, align the column headers and write the data in scientific notation

    Arguments:
    filename -- Self-explanatory
    desc -- The description of the file (see do_preamble)
    cols -- The column headers (see do_preamble)
    data -- List of arrays containing the data to write. All arrays must have the same length

    Keyword arguments:
    [See do_preamble]
    """
    # Check for problems
    try:
        assert len(set([len(arr) for arr in data])) == 1
    except AssertionError:
        print('Arrays containing data points do not all have the same length.'+'\n'+'Stopping.')
        return
    try:
        assert len(data) == len(cols)
    except AssertionError:
        print('Number of data arrays and column headers is not the same.'+'\n'+'Stopping.')
        return
    the_preamble = do_preamble(desc,cols,**kwargs)
    with open(filename,'w') as toexp:
        # Write the preamble
        for i in range(len(the_preamble)):
            toexp.write(the_preamble[i]+'\n')
        # Write the data points
        for i in range(len(data[0])):
            line = ''
            for j in range(len(data)):
                line += mystr(data[j][i])+' '
            line += '\n'
            toexp.write(line)
