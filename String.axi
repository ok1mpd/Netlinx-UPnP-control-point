PROGRAM_NAME='String'

define_constant
WC_FORMAT_UTF8          = 3 	 //Unicode format type
WC_FORMAT_TP            = 100	 //Unicode format type for panels

STRING_RETURN_SIZE_LIMIT	= 2024


DEFINE_FUNCTION sendUNItext2arr(dev panel[] ,integer adr, char text[])
{
STACK_VAR WIDECHAR strSTRING1[600]
STACK_VAR CHAR strSTRING2[600]
strSTRING1 = WC_DECODE(text,WC_FORMAT_UTF8,1) // Used to Decode 
strSTRING2 = WC_ENCODE(strSTRING1,WC_FORMAT_TP,1)	
SEND_command panel,"'^UNI-',itoa(adr),',0,',strSTRING2"
}

define_function char[STRING_RETURN_SIZE_LIMIT] urlencodeToTP(char a[])
{
	stack_var char ret[STRING_RETURN_SIZE_LIMIT + 1]
	stack_var integer i

	for (i = 1; i <= length_string(a); i++) {
		if ((a[i] >= $30 && a[i] <= $39) ||			
			(a[i] >= $41 && a[i] <= $5a) ||			
			(a[i] >= $61 && a[i] <= $7a) ||			
			a[i] == '$' || a[i] == '-' || a[i] == '_' ||
			a[i] == '.' || a[i] == '+' || a[i] == '!' ||
			a[i] == '*' || a[i] == $27 || a[i] == '(' ||
			a[i] == ')' || a[i] == ',' || a[i] == '[' || a[i] == ']' ) {

			ret = "ret, a[i]"
		} else {
			ret = "ret, '%%', string_prefix_to_length(itohex(a[i]), '0', 2)"
		}
	}


	return ret
}


define_function char[STRING_RETURN_SIZE_LIMIT] string_prefix_to_length(
		char a[], char value, integer len)
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT]
	stack_var integer i



    if (length_string(a) < len) {
		for (i = length_string(a); i < len; i++) {
			ret = "value, ret"
		}
    }

    return "ret, a"
}



DEFINE_FUNCTION  char[STRING_RETURN_SIZE_LIMIT] SetCoverArtPath(char URL)
     {
   
     STACK_VAR CHAR cNewRMFStr[500] ;
     STACK_VAR CHAR cLstArtHost[500];
     STACK_VAR INTEGER nFBS ;
     STACK_VAR CHAR cFileName[500] ;
	  
	     
	       cFileName = URL;
	 
	    
		    cNewRMFStr = "'%P0'" ;
		    REMOVE_STRING(cFileName,'://',1) ;
		    nFBS = find_string(cFileName,'/',1)
		    if(nFBS)
			 {
			 STACK_VAR CHAR cPath[256] ;
			 
			 cLstArtHost = "cNewRMFStr,'%H',GET_BUFFER_STRING(cFileName,nFBS-1)" ;
			 cNewRMFStr = cLstArtHost ;
			 GET_BUFFER_CHAR(cFileName) ;
			 
			 WHILE(find_string(cFileName,'/',1))
			      {
			      cPath = "cPath,REMOVE_STRING(cFileName,'/',1)" ;
			      }
			 if(length_string(cPath))
			      {
			      SET_LENGTH_STRING(cPath,LENGTH_STRING(cPath)-1) ; //remove ending "/"
			      cNewRMFStr = "cNewRMFStr,'%A',cPath" ;
			      }
			      else
			      {
			      cNewRMFStr = "cNewRMFStr,'%A'" ;
			    }
			 cNewRMFStr = "cNewRMFStr,'%F',cFileName" ;
			 }
			 
  return cNewRMFStr
     }





define_function char[STRING_RETURN_SIZE_LIMIT] string_replace(char a[],
		char search[], char replace[])
{
	stack_var integer start
	stack_var integer end
	stack_var char ret[STRING_RETURN_SIZE_LIMIT]


	start = 1
	end = find_string(a, search, start)

	while (end) {
		ret = "ret, mid_string(a, start, end - start), replace"
		start = end + length_string(search)
		end = find_string(a, search, start)
	}

	ret = "ret, right_string(a, length_string(a) - start + 1)"

	return ret
}
