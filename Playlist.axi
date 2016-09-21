PROGRAM_NAME='Playlist'

define_variable
CHAR  sXMLString[150000]
CHAR  sNamePlaylist[20][20]
LONG  lPos
SLONG  slReturn
SLONG  slFile
SLONG  slResult
CHAR Buffer[1024]
sLONG NumFiles
LONG Entry
long slPos


DEFINE_FUNCTION DeletePlayListFromDir(integer ID)
{
FILE_DELETE("'\Playlist\',sNamePlaylist[ID],'.xml'")
LoadPlayListFromDir()
}

DEFINE_FUNCTION RESET_PalylistSelecter()
{
	integer ir
	for(ir=1; ir<21; ir++)
	{
	SEND_COMMAND vTP,"'^TXT-',itoa(500+ir),',0, '"
	sNamePlaylist[ir]=''
	}
}

DEFINE_FUNCTION LoadPlayListFromDir()
{
NumFiles=1
Entry=1

RESET_PalylistSelecter()

WHILE (NumFiles > 0)
    {
	NumFiles = FILE_DIR ('\Playlist', Buffer, Entry)
	if(find_string(Buffer,'.xml',1) and NumFiles <> -12){
	sNamePlaylist[Entry]=left_string(Buffer,find_string(Buffer,'.xml',1)-1)
	SEND_COMMAND vTP,"'^TXT-',itoa(500+Entry),',0,',sNamePlaylist[Entry]"
	}
	Entry = Entry + 1
    }
}

DEFINE_FUNCTION LoadPlayListFromFile(integer ID)
{
// Read XML File
FILE_SETDIR ('\Playlist\')
slFile = FILE_OPEN("sNamePlaylist[ID],'.xml'",1)
slResult = FILE_READ(slFile, sXMLString, MAX_LENGTH_STRING(sXMLString))
slResult = FILE_CLOSE (slFile)
//Convert To XML
slPos = 1
slReturn = STRING_TO_VARIABLE (Playlist, sXMLString, slPos)
PLtotal=Playlist[1].pTotal
ShowPL(1)
}

define_event

DATA_EVENT[vTP]
{
     STRING:
     {
	 LOCAL_VAR CHAR cBuf[32]
	 cBuf = DATA.TEXT

	 SELECT
	     {
		 ACTIVE(FIND_STRING(cBuf,'KEYB',1)):
		 {
		    REMOVE_STRING(cBuf,'KEYB-',1) 

			    // Convert To XML

			    lPos = 1
			    Playlist[1].pTotal=PLtotal
			    slReturn = VARIABLE_TO_STRING(Playlist, sXMLString, lPos)
			    
			    // Save Structure To Disk – XML
			    FILE_CREATEDIR('\Playlist\')
			    FILE_SETDIR ('\Playlist\')
			    slFile = FILE_OPEN("cBuf,'.xml'", 2)
			    slReturn = FILE_WRITE(slFile, sXMLString, LENGTH_STRING(sXMLString))
			    slReturn = FILE_CLOSE(slFile)

		 }
	 }
    }
}

