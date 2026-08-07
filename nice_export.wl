(* Copyright (c) Killian Bouzoud.                                                    *)
(* Licensed under the MIT license. See LICENSE file in the project root for details. *)

GetInfos::usage = "Get information about the file being executed. Returns in order:\n\
- The Mathematica version, in the form XXX.YYY.ZZZ\n\
- The name of the file being executed, with full path\n\
- The current datetime, down to the second";
GetInfos[]:=Module[{now="",script="",version=""},
    now = StringReplace[
        DateString["ISODateTime"], "T"->" "
    ];
    If[$Notebooks,
        script = NotebookFileName[];
    ,
        script = $CommandLine[[3]];
        script = FileNameJoin[{Directory[],script}];
    ];
    version = StringReplace[$Version,"for"~~___->""];
    version = StringReplace[version," "->""];
    Return[{version,script,now}];
]

MyString::usage = "Converts the argument to scientific notation. Returns a string. [Defaults to 16 digits for now]";
MyString[num_]:=Module[{mantissa,exponent,res="",thee=""},
    digits = 16;
    expdigits = 2;
    (* First part *)
    mantissa = MantissaExponent[num][[1]];
    mantissa = RealDigits[mantissa,10,Automatic];
    mantissa = First[mantissa];
    mantissa = PadRight[mantissa,digits,0];
    mantissa = ToString/@mantissa;
    mantissa = StringJoin[mantissa];
    (* Second part *)
    exponent = MantissaExponent[num][[2]];
    If[exponent>0,
        thee = "E+";
    ,
        If[exponent<0,
            thee = "E-";
        ,
            thee = "E+"
        ]
    ];
    exponent = IntegerDigits[exponent,10,expdigits];
    exponent = ToString/@exponent;
    exponent = StringJoin[exponent];
    If[num<0,
        res = res<>"-";
    ];
    res = res<>"0.";
    res = res<>mantissa;
    res = res<>thee;
    res = res<>exponent;
    If[Read[StringToStream[res],Number]==num,
        Return[res];
    ,
        Return["NaN"];
    ];
]

Options[DoTheExport] = {comment->"#",full->True,parameters-><||>};
DoTheExport::usage = "Exports the data, formatted correctly, to a file.\n\
Positional arguments (in order):\n\
filename -- Self-explanatory, name of the file to export the data to\n\
desc -- LIST of strings composing each line of the file description\n\
cols -- LIST of strings containg the header for each data column\n\
data -- LIST of arrays containing the data to export\n\
Optional arguments:\n\
comment -- Symbol to use to indicate non-data lines [default: #]\n\
full -- Whether to include the full path of the script being run [default: True]\n\
parameters -- Dictionary (Association object) with the names and values of parameters [default: <||> (empty)]";
DoTheExport[filename_,desc_,cols_,data_,OptionsPattern[] ]:=Module[{stream,infos,infosdesc,theline,offset,com,params,len,allkeys,allvals,theval,thestr},
    com = OptionValue[comment];
    infos = GetInfos[];
    infosdesc = {"Data computed using Mathematica version:","Data computed in:","Data exported at:"};
    (* Test if all data arrays have the same length *)
    If[!Count[Length/@data,Length[data[[1]]] ]==Length[data],
        Print["Not all data arrays have the same length."<>"\n"<>"Stopping."];
        Return[];
    ];
    (* Test if there are enough column headers *)
    If[!Length[cols]==Length[data],
        Print["Not enough column headers."<>"\n"<>"Stopping."];
        Return[];
    ];
    (* Shorten the file path if necessary *)
    If[!OptionValue[full],
        infos[[2]] = FileNameTake[infos[[2]]];
    ];
    (* Write to the file *)
    stream = OpenWrite[filename];
    (* Write the description *)
    Do[
        theline = com<>" "<>desc[[i]];
        WriteString[stream,theline<>"\n"];
    ,{i,Length[desc]}];
    Do[
        WriteString[stream,com<>" "<>infosdesc[[i]]<>" "<>infos[[i]]<>"\n"];
    ,{i,Length[infos]}];
    (* Write the parameters *)
    params = OptionValue[parameters];
    If[Length[params] != 0,
        len = Length[params];
        allkeys = Keys[params];
        allvals = Values[params];
        WriteString[stream,com<>" Parameters:"<>"\n"];
        Do[
            thestr = com<>" ";
            thestr = thestr<>allkeys[[i]]<>": ";
            theval = allvals[[i]];
            If[Head[theval] === Integer,
                thestr = thestr<>ToString[theval];
                ,
                If[Head[theval] === Real, 
                    thestr = thestr<>MyString[theval];
                    ,
                    If[Head[theval] === String,
                        thestr = thestr <> "'" <> theval <> "'";
                    ];
                ];
            ];
            WriteString[stream,thestr<>"\n"];
        ,{i,len}];
    ];
    (* Write the column headers *)
    theline = com<>" ";
    Do[
        offset = 0;
        If[i==1,
            offset = 16+5-StringLength[cols[[i]]];
            ,
            offset = 16+7-StringLength[cols[[i]]];
        ];
        theline = theline<>cols[[i]]<>StringRepeat[" ",offset];
    ,{i,Length[cols]}];
    WriteString[stream,theline<>"\n"];
    (* Write the data *)
    Do[
        theline = "";
        Do[
            theline = theline<>MyString[data[[j,i]]]<>" ";
        ,{j,Length[data]}];
        WriteString[stream,theline<>"\n"];
    ,{i,Length[data[[1]]]}];
    Close[stream];
]

Print["Loaded nice_export"];
