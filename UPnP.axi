
PROGRAM_NAME='UPnP'


DEFINE_TYPE
    structure DEVICE
    {
		char Name[100]
		char Ico[500]
		char IP[30]
		integer Port
		char type[500]
		char UDN[500]
		char ContPath[100]
		char controlURL[300]
		char controlURLService[300]
    }
    
     structure BRitem//browse
    {
		char id[6]
		char nam[80]
		char path[100]//path in server database
		char pathobr[100]//path image
		integer type //adresar=0 - skladba=1
		char metadata[2000]
    }

    structure PLitem//playlist
    {
		char nam[100]
		char path[100]//path in server database
		char pathobr[100]//path obrazku
		char metadata[2000]
		char image[500]
		integer pTotal
    }
    
    structure Now
    {
	char Title[100]
	char Album[100]
	char Artist[100]
	char RelTime[10]
	char Duration[10]
	char IMG[300]
	char Status[50]
    }
	
	
DEFINE_CONSTANT

MAX_PL_LENGTH = 100

    
DEFINE_VARIABLE

	Now NowPlay
	integer RelTimeV
	integer DurationV
	
	char DATAREC_UP[8000]
	char DATAREC_UP_P[8000]
	char DATAREC_UP_TCP[160000]
	DEVICE Devices[20]
	DEVICE Devicer[20]
	integer posStart
	integer posEnd
	integer posStartT
	integer posEndT
	integer deviceI
	integer deviceir
	integer iClear
	integer CoverImage[20]
	integer ActualSelectPlayer
	
	integer lev = 0
	char arLev[10][6]

	char IPSendHTTP[20][30]
	char GETSendHTTP[20][500]
	integer PortSendHTTP[20]
	
	integer ui
	integer uj
	integer ti
	char S[3500]
	
	volatile BRitem Browse[200]
	volatile PLitem Playlist[100]
	BRitem PLone
	long Rlen
	long len
	
	long pos
	long en
	long pos1
	long en1
	integer typ
	integer i
	char res[100]
	volatile integer cur10
	volatile integer curPocet
	volatile long curServer
	volatile char patern[6]
	volatile integer ipatern

	volatile integer PLtotal
	volatile integer PLhraje
	volatile integer PLcur10
	volatile integer PLprijem
	
	integer a
	

DEFINE_FUNCTION SEARCH_M()
{
	IP_CLIENT_CLOSE (dvUPnPClient.Port)
	IP_SERVER_CLOSE (dvUPnPServerMC.Port)
	deviceI=0
	deviceir=0
	arLev[1] = '0'
	lev=0
	
	FOR (iClear = 1; iClear <=20; iClear++)
    {
		DATAREC_UP_TCP[iClear]="''"
		
		Devices[iClear].IP="''"
		Devices[iClear].Ico="''"
		Devices[iClear].Name="''"
		Devices[iClear].type="''"
		Devices[iClear].UDN="''"
		Devices[iClear].Port=0
		
		Devicer[iClear].IP="''"
		Devicer[iClear].Ico="''"
		Devicer[iClear].Name="''"
		Devicer[iClear].type="''"
		Devicer[iClear].UDN="''"
		Devicer[iClear].Port=0
			
		CoverImage[iClear]=0
    }
	
	IP_MC_SERVER_OPEN (dvUPnPServerMC.Port,'239.255.255.250',1900)
	IP_CLIENT_OPEN    (dvUPnPClient.Port,'239.255.255.250',1900,IP_UDP_2WAY)

	wait 1 SEND_STRING dvUPnPClient,"
	'M-SEARCH * HTTP/1.1',$0D,$A,
	'ST:urn:schemas-upnp-org:device:MediaServer:1',$0D,$A,
	'MX: 2',$0D,$A,
	'MAN: "ssdp:discover"',$0D,$A,
	'HOST: 239.255.255.250:1900',$0D,$A,$0D,$A"
	
	wait 2 SEND_STRING dvUPnPClient,"
	'M-SEARCH * HTTP/1.1',$0D,$A,
	'ST:urn:schemas-upnp-org:device:MediaRenderer:1',$0D,$A,
	'MX: 2',$0D,$A,
	'MAN: "ssdp:discover"',$0D,$A,
	'HOST: 239.255.255.250:1900',$0D,$A,$0D,$A"

}

DEFINE_FUNCTION RESET_Browse()
{
	integer ir
	for(ir=1; ir<11; ir++)
	{
	SEND_COMMAND vTP,"'^TXT-',itoa(ir),',0, '"
	SEND_LEVEL vTP, 10+ir, 0
	}
}

DEFINE_FUNCTION RESET_Browse_Player()
{
	integer ir
	for(ir=1; ir<11; ir++)
	{
	SEND_COMMAND vTP,"'^TXT-',itoa(200+ir),',0, '"
	}
}

DEFINE_FUNCTION SelectPlayer(integer ID)
{
ActualSelectPlayer=ID
sendUNItext2arr(vTP ,200, Devicer[ID].Name)
SetPlayModeNormal(ActualSelectPlayer)
}

DEFINE_FUNCTION SEND_TO_PANEL(integer its)
{
	sendUNItext2arr(vTP ,its, Devices[its].Name)
	SEND_LEVEL vTP, 10+its, 3
	SEND_COMMAND vTP,"'^TXT-101,0,',itoa(cur10+1),'/',itoa(((curPocet-1)/10)+1)"
}

DEFINE_FUNCTION SEND_TO_PANEL_R(integer its)
{
	sendUNItext2arr(vTP ,200+its, Devicer[its].Name)
}


DEFINE_FUNCTION SetPlayModeNormal(integer ID)
{
	S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetPlayMode xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><NewPlayMode>NORMAL</NewPlayMode></u:SetPlayMode></s:Body></s:Envelope>'"
	http_post_SOAP_ACTION("'http://',Devicer[ID].IP,':',itoa(Devicer[ID].port),Devicer[ID].controlURL",s,'SetPlayMode')
}


DEFINE_FUNCTION SetPlayFromPlayList(integer ID)
{
id=10*PLcur10+id

if(Playlist[ID].metadata='iradio') {

    PlayRadioFromPlayList(ID)
    
}else{

S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><CurrentURI>http://',Playlist[ID].path,'</CurrentURI>'
,'<CurrentURIMetaData>&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;&lt;DIDL-Lite xmlns=&quot;urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/&quot; xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot; xmlns:upnp=&quot;urn:schemas-upnp-org:metadata-1-0/upnp/&quot; xmlns:dlna=&quot;urn:schemas-dlna-org:metadata-1-0/&quot;&gt;'
,Playlist[ID].metadata,'&lt;/DIDL-Lite&gt;</CurrentURIMetaData>'
,'</u:SetAVTransportURI></s:Body></s:Envelope>'"
	
	http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'SetAVTransportURI')
	
	pos = find_string(Playlist[ID].metadata, 'upnp:albumArtURI', 1)
			if(pos>0)
			{
			pos = find_string(Playlist[ID].metadata, '&gt;', pos)
			en  = find_string(Playlist[ID].metadata, '&lt', pos+4)
			NowPlay.IMG = SetCoverArtPath(mid_string(Playlist[ID].metadata, pos+4, en-pos-4))
			SEND_COMMAND vTP,"'^RMF-NowPlaying,',NowPlay.IMG"
			}	
	
	
	wait 3 SetPlay()
    }
}
DEFINE_FUNCTION SetPlayFromBrowse(integer ID)
{

S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><CurrentURI>http://',Browse[ID].path,'</CurrentURI>'
,'<CurrentURIMetaData>&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;&lt;DIDL-Lite xmlns=&quot;urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/&quot; xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot; xmlns:upnp=&quot;urn:schemas-upnp-org:metadata-1-0/upnp/&quot; xmlns:dlna=&quot;urn:schemas-dlna-org:metadata-1-0/&quot;&gt;'
,Browse[ID].metadata,'&lt;/DIDL-Lite&gt;</CurrentURIMetaData>'
,'</u:SetAVTransportURI></s:Body></s:Envelope>'"

	pos = find_string(Browse[ID].metadata, 'upnp:albumArtURI', 1)
			if(pos>0)
			{
			pos = find_string(Browse[ID].metadata, '&gt;', pos)
			en  = find_string(Browse[ID].metadata, '&lt', pos+4)
			NowPlay.IMG = SetCoverArtPath(mid_string(Browse[ID].metadata, pos+4, en-pos-4))
			SEND_COMMAND vTP,"'^RMF-NowPlaying,',NowPlay.IMG"
			}

	http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'SetAVTransportURI')
	wait 3 SetPlay()
}


DEFINE_FUNCTION SetPlay()
{
S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:Play xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Play></s:Body></s:Envelope>'"
http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'Play')
}

DEFINE_FUNCTION SetPause()
{
S="'<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><u:Pause xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID></u:Pause></s:Body></s:Envelope>'"
http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'Pause')
}

DEFINE_FUNCTION GetPositionInfo()
{
S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetPositionInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID></u:GetPositionInfo></s:Body></s:Envelope>'"
http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'GetPositionInfo')
}

DEFINE_FUNCTION GetTransportInfo()
{
S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetTransportInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID></u:GetTransportInfo></s:Body></s:Envelope>'"
http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURL",s,'GetTransportInfo')
}

DEFINE_FUNCTION SetVolume(integer Val)
{
S="'<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel><DesiredVolume>',itoa(Val),'</DesiredVolume></u:SetVolume></s:Body></s:Envelope>'"
http_post_SOAP_ACTION("'http://',Devicer[ActualSelectPlayer].IP,':',itoa(Devicer[ActualSelectPlayer].port),Devicer[ActualSelectPlayer].controlURLService",s,'SetVolume')
}




DEFINE_FUNCTION GetCont(char strid[])
{

	
	S="'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">',
	'<s:Body><u:Browse xmlns:u="urn:schemas-upnp-org:service:ContentDirectory:1">',
	'<ObjectID>',strid,'</ObjectID>',
	'<BrowseFlag>BrowseDirectChildren</BrowseFlag>',
	'<Filter>*</Filter>',
	'<StartingIndex>0</StartingIndex>',
	'<RequestedCount>200</RequestedCount>',
	'<SortCriteria></SortCriteria>',
	'</u:Browse>',
	'</s:Body>',
	'</s:Envelope>'"
	
	http_post_SOAP_ACTION("'http://',Devices[curServer].IP,':',itoa(Devices[curServer].port),Devices[curServer].ContPath",s,'Browse')
}

DEFINE_FUNCTION getBrowse(integer num)
{
if((10*cur10+num)<=curPocet){ 

if(Browse[10*cur10+num].type=1 and lev>1){
    SetPlayFromBrowse(10*cur10+num)
    }
    else
    {

	    RESET_Browse()
	    lev++
	    if(lev=1)curServer = num
	    if(lev>1)arLev[lev] = Browse[10*cur10+num].id
	    PLprijem = 0
	    GetCont(arLev[lev])
    }
}
}


DEFINE_FUNCTION HomeBrowse()
{
    RESET_Browse() 
		    lev=0
		    curPocet=deviceI
		    For(i=1; i<= DEVICEI; i++)
			{
			SEND_TO_PANEL(i)
			}
}

DEFINE_FUNCTION backBrowse()
{
local_var integer i
	if(lev>1){
		    lev=lev-1  
		    cur10=0  
		    RESET_Browse() 
		    PLprijem=0 
		    GetCont(arLev[lev])
		}
		else
		{
		    RESET_Browse() 
		    lev=0
		    curPocet=deviceI
		    For(i=1; i<= DEVICEI; i++)
			{
			SEND_TO_PANEL(i)
			}
		}
	
}

DEFINE_FUNCTION ShowBRup()
{
	if(cur10 > 0){cur10--  ShowBR() }
}

DEFINE_FUNCTION ShowBRdw()
{
	if(curPocet >(10*cur10+10)){cur10++  ShowBR() }
}

DEFINE_FUNCTION ShowBR()
{
	stack_var 
	long i
	long j
	

	
	
	
	RESET_Browse()
	For(i=10*cur10+1; i<= 10*cur10+10; i++)
	{
		j++
		sendUNItext2arr(vTP ,j, Browse[i].nam)
		if(Browse[i].type) {SEND_LEVEL vTP, 10+j, 2}else {SEND_LEVEL vTP, 10+j, 1}
		if(i=curPocet) break;	
	}
	
	
	SEND_COMMAND vTP,"'^TXT-101,0,',itoa(cur10+1),'/',itoa(((curPocet-1)/10)+1)"

}



// Playlist funkce ************************************************************

DEFINE_FUNCTION put2PL(integer num)
{
	stack_var integer curnum
	
	if(PLtotal< MAX_PL_LENGTH)
	{
		curnum = 10*cur10+num
		if(Browse[curnum].type=1)//pisnicka
		{
			PLtotal++
			Playlist[PLtotal].nam = Browse[curnum].nam
			Playlist[PLtotal].path = Browse[curnum].path
			Playlist[PLtotal].metadata = Browse[curnum].metadata
			ShowPL(PLtotal)
			PLcur10=(PLtotal-1)/10
		}
		if(Browse[curnum].type=0)//adresar
		{
			PLprijem = 1
			GetCont(Browse[curnum].id)
		}
	}
}

DEFINE_FUNCTION RESET_Playlist()
{
	stack_var integer ir
	for(ir=51; ir<=60; ir++){ SEND_COMMAND vTP,"'^TXT-',itoa(ir),',0, '" }
}

DEFINE_FUNCTION ClearPlaylist()
{
	RESET_Playlist()
	PLcur10 = 0
	PLtotal = 0
	SEND_COMMAND vTP,"'^TXT-151,0,',itoa(PLtotal)"//celkem
	SEND_COMMAND vTP,"'^TXT-152,0,1/1'"
	
}

DEFINE_FUNCTION RemoveFromPlaylist(integer num)
{
	stack_var 
	integer i
	if((PLtotal >0) and (10*PLcur10+num <= PLtotal))
	{
		RESET_Playlist()

		For(i= 10*PLcur10+num; i< PLtotal; i++)
		{
			Playlist[i].nam = Playlist[i+1].nam
			Playlist[i].path = Playlist[i+1].path
		}
		PLtotal--
		ShowPL(10*PLcur10+num)
	}
}

DEFINE_FUNCTION ShowPLup()
{
	if(PLcur10 > 0){ PLcur10--  ShowPL(10*PLcur10+10) }
}

DEFINE_FUNCTION ShowPLdw()
{
	if(PLtotal >(10*PLcur10+10)){ PLcur10++  ShowPL(10*PLcur10+10) }
}

DEFINE_FUNCTION ShowPL(integer num)
{
	stack_var 
	integer i
	integer j
	
	if(num>PLtotal)num = PLtotal
	RESET_Playlist()
	For(i= 10*((num-1)/10)+1; i<= 10*(num/10)+10; i++)
	{
		j++
		sendUNItext2arr(vTP,50+j,Playlist[i].nam) 
		if(i=PLtotal)i = 999		
	}
	SEND_COMMAND vTP,"'^TXT-151,0,',itoa(PLtotal)"//celkem	
	if(PLtotal >0) PLcur10 = (num-1)/10 else PLcur10 =0
	if(PLtotal >0)i = (PLtotal-1)/10 +1 else i =1
	SEND_COMMAND vTP,"'^TXT-152,0,',itoa(PLcur10+1),'/',itoa(i)"//celkem 10
}
//******************************************************************************



DEFINE_START
{

	create_buffer dvUPnPClient,DATAREC_UP
}



DEFINE_EVENT



DATA_EVENT [dvUPnPClient]
{
	STRING:	
	{
		wait 20
		{
			posStart=1
			posEnd=1
			ui = 0
			uj = 0
			
			DATAREC_UP_P=upper_string(DATAREC_UP)
			{
				posStart=find_string(DATAREC_UP_P,"'LOCATION'",1)
				while(posStart)
				{
				
					ui++
					posStart = find_string(DATAREC_UP_P,"'HTTP://'",posStart+8)+7
					posEnd=find_string(DATAREC_UP_P,"':'",posStart+1)
					IPSendHTTP[ui] = mid_string(DATAREC_UP_P,posStart,posEnd-posStart)
					posStart = posEnd+1
					posEnd = find_string(DATAREC_UP_P,"'/'",posStart)
					PortSendHTTP[ui] = atoi(mid_string(DATAREC_UP_P,posStart,posEnd-posStart))
					posStart = posEnd+1
					if(DATAREC_UP_P[posStart]<>$0D){
					posEnd = find_string(DATAREC_UP_P,"$0D",posStart+2)
			
					GETSendHTTP[ui] = mid_string(DATAREC_UP,posStart,posEnd-posStart)
					}
					else 
					{
					GETSendHTTP[ui] =''
					}
					
					posStart=find_string(DATAREC_UP_P,"'LOCATION'",posEnd)

					for(ti=1; ti<ui; ti++)		//maze duplicitni zaznamy
					{ if(IPSendHTTP[ui]=IPSendHTTP[ti])
						{ if(PortSendHTTP[ui]=PortSendHTTP[ti])
							{ if(GETSendHTTP[ui]=GETSendHTTP[ti])	
							{ ui=ui-1  ti=21 }
					}}}
				}
			}
			deviceI=0
			{
				long_while(uj < ui)
				{
				uj++
				http_get("'http://',IPSendHTTP[uj],':',itoa(PortSendHTTP[uj]),'/',GETSendHTTP[uj]")
				
			
			}
		}
	}}
}

DEFINE_FUNCTION http_response_received(long idr, char host[], http_response resp)
{
local_var char device_type[200]
	
	
	if(find_string(resp.body,'<opml version="1">',1))
	{
	http_response_received_radio(resp)
	}

	DATAREC_UP_TCP = resp.body
	if(find_string(DATAREC_UP_TCP,'<root',1))													   					   
	if(find_string(DATAREC_UP_TCP,'xmlns="urn:schemas-upnp-org:device-1-0',1) or find_string(DATAREC_UP_TCP,"'xmlns=',$27,'urn:schemas-upnp-org:device-1-0'",1) or find_string(DATAREC_UP_TCP,'urn:schemas-dlna-org:device-1-0',1))
	{			      
	posStartT=0
	posEndT=0	
	
	
	if(find_string(DATAREC_UP_TCP,"'<deviceType>'",1)){
	posStartT=find_string(DATAREC_UP_TCP,"'<deviceType>'",1)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</deviceType>'",posStartT)
	device_type=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	device_type=lower_string(device_type)
	}
	
	if(find_string(device_type,'mediaserver',1))
	{
	
	deviceI++
	curPocet=deviceI
	posEndT = (find_string(host,"':'",1))
	Devices[deviceI].IP = mid_string(host,1,posEndT-1)
	Devices[deviceI].Port = atoi(mid_string(host,posEndT+1,10))
	
	
	if(find_string(DATAREC_UP_TCP,"'<deviceType>'",1)){
	posStartT=find_string(DATAREC_UP_TCP,"'<friendlyName>'",1)+14
	posEndT=find_string(DATAREC_UP_TCP,"'</friendlyName>'",posStartT)
	Devices[deviceI].Name=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}

	if(find_string(DATAREC_UP_TCP,"'<deviceType>'",1)){
	posStartT=find_string(DATAREC_UP_TCP,"'<deviceType>'",1)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</deviceType>'",posStartT)
	Devices[deviceI].type=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
	
	posStartT=find_string(DATAREC_UP_TCP,"'<iconList>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<iconList>'",posStartT)
	posStartT=find_string(DATAREC_UP_TCP,"'<url>'",posStartT)+5
	posEndT=find_string(DATAREC_UP_TCP,"'</url>'",posStartT)
	Devices[deviceI].Ico=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
	
	posStartT=find_string(DATAREC_UP_TCP,"'<UDN>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<UDN>'",posStartT)+5
	posEndT=find_string(DATAREC_UP_TCP,"'</UDN>'",posStartT)
	Devices[deviceI].UDN=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}

	posStartT=find_string(DATAREC_UP_TCP,"'ContentDirectory:'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<controlURL>'",posStartT)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</controlURL>'",posStartT)
	Devices[deviceI].ContPath=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
	}
	
	
	SEND_TO_PANEL(deviceI)
	
	if(find_string(device_type,"'mediarenderer'",1)) 
	{
	deviceir++
	
	posEndT = (find_string(host,"':'",1))
	Devicer[deviceir].IP = mid_string(host,1,posEndT-1)
	Devicer[deviceir].Port = atoi(mid_string(host,posEndT+1,10))
	
	
	if(find_string(DATAREC_UP_TCP,"'<deviceType>'",1)){
	posStartT=find_string(DATAREC_UP_TCP,"'<friendlyName>'",1)+14
	posEndT=find_string(DATAREC_UP_TCP,"'</friendlyName>'",posStartT)
	Devicer[deviceir].Name=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}

	if(find_string(DATAREC_UP_TCP,"'<deviceType>'",1)){
	posStartT=find_string(DATAREC_UP_TCP,"'<deviceType>'",1)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</deviceType>'",posStartT)
	Devicer[deviceir].type=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
	
	posStartT=find_string(DATAREC_UP_TCP,"'<iconList>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<iconList>'",posStartT)
	posStartT=find_string(DATAREC_UP_TCP,"'<url>'",posStartT)+5
	posEndT=find_string(DATAREC_UP_TCP,"'</url>'",posStartT)
	Devicer[deviceir].Ico=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
	
	posStartT=find_string(DATAREC_UP_TCP,"'<UDN>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<UDN>'",posStartT)+5
	posEndT=find_string(DATAREC_UP_TCP,"'</UDN>'",posStartT)
	Devicer[deviceir].UDN=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}

	posStartT=find_string(DATAREC_UP_TCP,"'ContentDirectory:'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<controlURL>'",posStartT)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</controlURL>'",posStartT)
	Devicer[deviceir].ContPath=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	}
		
	
	posStartT=find_string(DATAREC_UP_TCP,"'<serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<controlURL>'",posStartT)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</controlURL>'",posStartT)
	Devicer[deviceir].controlURL=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	if(Devicer[deviceir].controlURL[1]<>'/') Devicer[deviceir].controlURL="'/',Devicer[deviceir].controlURL"
	}
	
	posStartT=find_string(DATAREC_UP_TCP,"'<serviceType>urn:schemas-upnp-org:service:RenderingControl:1</serviceType>'",1)
	if(posStartT<>0){
	posStartT=find_string(DATAREC_UP_TCP,"'<controlURL>'",posStartT)+12
	posEndT=find_string(DATAREC_UP_TCP,"'</controlURL>'",posStartT)
	Devicer[deviceir].controlURLService=mid_string(DATAREC_UP_TCP,posStartT,posEndT-posStartT)
	if(Devicer[deviceir].controlURLService[1]<>'/') Devicer[deviceir].controlURLService="'/',Devicer[deviceir].controlURLService"
	}
	
	
	}
	SEND_TO_PANEL_R(deviceir)

   } 
   
   find_string(DATAREC_UP_TCP,'<NumberReturned>0</NumberReturned>',1)
   if(find_string(DATAREC_UP_TCP,'xmlns:u="urn:schemas-upnp-org:service:ContentDirectory:1',1) and  !find_string(DATAREC_UP_TCP,'<NumberReturned>0</NumberReturned>',1))
	{
	
			en = 1
			i = 1
			pos = 1
			
			if(find_string(DATAREC_UP_TCP, 'container id=&quot;', 1)){ patern='&quot;' ipatern=1   }
			else if(find_string(DATAREC_UP_TCP, 'container id="', 1)){ patern='"' ipatern=2   }
			
if(PLprijem ==0)//cte se Browse
{
			cur10 = 0

			While(pos > 0)
			{
				if(find_string(DATAREC_UP_TCP, "'container id=',patern", en)){ //adresare
				pos = find_string(DATAREC_UP_TCP, "'container id=',patern", en)
				typ = 0
				}
				else if(find_string(DATAREC_UP_TCP, "'item id=',patern", en)){ //pisnicky
				
				
				
				pos1=pos
				pos1 = find_string(DATAREC_UP_TCP, '&lt;item', pos1+1)
				en1  = find_string(DATAREC_UP_TCP, 'item&gt;', pos1+8)
				Browse[i].metadata = mid_string(DATAREC_UP_TCP, pos1, en1-pos1+8)
				
				pos = find_string(DATAREC_UP_TCP, "'item id=',patern", en)
				
				typ = 1
				}
				
				If(pos < en){pos=0}
				else
				{
				
					if(ipatern=1)//uvozovky ve formatu - '&quot;'
					{
						en  = find_string(DATAREC_UP_TCP, '&quot', pos+18)
						res = mid_string(DATAREC_UP_TCP, pos+19, en-pos-19)
						Browse[i].id= res
						Browse[i].type= typ
						
						
						
						pos = find_string(DATAREC_UP_TCP, '&lt;dc:title', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+16)
						res = mid_string(DATAREC_UP_TCP, pos+16, en-pos-16)
						Browse[i].nam = res
						if(typ=1)
							{
		    
							pos = find_string(DATAREC_UP_TCP, 'protocolInfo=', pos+1)
							pos = find_string(DATAREC_UP_TCP, '&gt;http:', pos+1)
							en  = find_string(DATAREC_UP_TCP, '&lt', pos+11)
							res = mid_string(DATAREC_UP_TCP, pos+11, en-pos-11)
							Browse[i].path = res	
	
							}
						else{Browse[i].path = ''}
					}
					
					if(ipatern=2)//uvozovky jako - '"'
						{
						en  = find_string(DATAREC_UP_TCP, '"', pos+14)
						res = mid_string(DATAREC_UP_TCP, pos+14, en-pos-14)
						Browse[i].id= res
						Browse[i].type= typ
						
						
						
						pos = find_string(DATAREC_UP_TCP, '&lt;dc:title', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+16)
						res = mid_string(DATAREC_UP_TCP, pos+16, en-pos-16)
						Browse[i].nam = res
						if(typ=1)
							{
							pos = find_string(DATAREC_UP_TCP, 'protocolInfo=', pos+1)
							pos = find_string(DATAREC_UP_TCP, '&gt;http:', pos+1)
							en  = find_string(DATAREC_UP_TCP, '&lt', pos+11)
							res = mid_string(DATAREC_UP_TCP, pos+11, en-pos-11)
							Browse[i].path = res							
							}
						else{Browse[i].path = ''}
					}
					
					if(i<11) 
					{
					sendUNItext2arr(vTP,i,Browse[i].nam)
					if(Browse[i].type) {SEND_LEVEL vTP, 10+i, 2}else {SEND_LEVEL vTP, 10+i, 1}
					}
					
					
					i++
				}
			}
			curPocet = i-1
			SEND_COMMAND vTP,"'^TXT-101,0,',itoa(cur10+1),'/',itoa(((curPocet-1)/10)+1)"
			
}

if(PLprijem ==1)//cte se do Playlistu
{
			While(pos > 0)
			{
				if(find_string(DATAREC_UP_TCP, "'item id=',patern", en)){ //pisnicky
				
					pos1=pos
					pos1 = find_string(DATAREC_UP_TCP, '&lt;item', pos1+1)
					en1  = find_string(DATAREC_UP_TCP, 'item&gt;', pos1+8)
					PLone.metadata = mid_string(DATAREC_UP_TCP, pos1, en1-pos1+8)
				
				pos = find_string(DATAREC_UP_TCP, "'item id=',patern", en)
				}
				else
				{ pos = 0 }
				
				If(pos < en){pos=0}
				else
				{
					if(ipatern=1)//uvozovky ve formatu - '&quot;'
					{
						en  = find_string(DATAREC_UP_TCP, '&quot', pos+18)
						res = mid_string(DATAREC_UP_TCP, pos+19, en-pos-19)
						//PLone.id= res
						//PLone.type= typ
						
					

						pos = find_string(DATAREC_UP_TCP, '&lt;dc:title', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+16)
						res = mid_string(DATAREC_UP_TCP, pos+16, en-pos-16)
						PLone.nam = res

						pos = find_string(DATAREC_UP_TCP, 'protocolInfo=', pos+1)
						pos = find_string(DATAREC_UP_TCP, '&gt;http:', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+11)
						res = mid_string(DATAREC_UP_TCP, pos+11, en-pos-11)
						PLone.path = res						
					}
					
					if(ipatern=2)//uvozovky jako - '"'
					{
						en  = find_string(DATAREC_UP_TCP, '"', pos+14)
						res = mid_string(DATAREC_UP_TCP, pos+14, en-pos-14)
						
						pos = find_string(DATAREC_UP_TCP, '&lt;item', pos+1)
						en  = find_string(DATAREC_UP_TCP, 'item&gt;', pos+8)
						PLone.metadata = mid_string(DATAREC_UP_TCP, pos, en-pos+8)
						//PLone.id= res
						//PLone.type= typ
						pos = find_string(DATAREC_UP_TCP, '&lt;dc:title', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+16)
						res = mid_string(DATAREC_UP_TCP, pos+16, en-pos-16)
						PLone.nam = res

						pos = find_string(DATAREC_UP_TCP, 'protocolInfo=', pos+1)
						pos = find_string(DATAREC_UP_TCP, '&gt;http:', pos+1)
						en  = find_string(DATAREC_UP_TCP, '&lt', pos+11)
						res = mid_string(DATAREC_UP_TCP, pos+11, en-pos-11)
						PLone.path = res							
					}
					if(PLtotal< MAX_PL_LENGTH)
					{
						PLtotal++
						Playlist[PLtotal].nam = PLone.nam
						Playlist[PLtotal].path = PLone.path
						Playlist[PLtotal].metadata = PLone.metadata
					}
				}		
						
			}
			
			ShowPL(PLtotal)			
						
}
	
	
   }
   
   
    if(find_string(DATAREC_UP_TCP,'GetPositionInfoResponse',1))
	{
	
	
			
			pos = find_string(DATAREC_UP_TCP, '&lt;dc:title', 1)
			en  = find_string(DATAREC_UP_TCP, '&lt', pos+16)
			if(pos>0) {
			NowPlay.title = mid_string(DATAREC_UP_TCP, pos+16, en-pos-16)
			}else{
			NowPlay.title = "'-'"
			}
			
			pos = find_string(DATAREC_UP_TCP, '&lt;upnp:album&gt;', 1)
			en  = find_string(DATAREC_UP_TCP, '&lt', pos+18)
			if(pos>0) {
			NowPlay.album = mid_string(DATAREC_UP_TCP, pos+18, en-pos-18)
			}else{
			NowPlay.album = "'-'"
			}
			
			pos = find_string(DATAREC_UP_TCP, '&lt;upnp:artist&gt;', 1)
			en  = find_string(DATAREC_UP_TCP, '&lt', pos+19)
			if(pos>0) {
			NowPlay.artist = mid_string(DATAREC_UP_TCP, pos+19, en-pos-19)
			}else{
			NowPlay.artist = "'-'"
			}
			
			pos = find_string(DATAREC_UP_TCP, 'upnp:albumArtURI', 1)
			if(pos>0)
			{
			pos = find_string(DATAREC_UP_TCP, '&gt;', pos)
			en  = find_string(DATAREC_UP_TCP, '&lt', pos+4)
			NowPlay.IMG = SetCoverArtPath(mid_string(DATAREC_UP_TCP, pos+4, en-pos-4))
			//NowPlay.IMG = mid_string(DATAREC_UP_TCP, pos+4, en-pos-4)
			SEND_COMMAND vTP,"'^RMF-NowPlaying,',NowPlay.IMG"
			}
			
			
			
			pos = find_string(DATAREC_UP_TCP, '<TrackDuration>', 1)+15
			en  = find_string(DATAREC_UP_TCP, '</TrackDuration>', pos)
			NowPlay.Duration = mid_string(DATAREC_UP_TCP, pos, en-pos)
			
			
			pos = find_string(DATAREC_UP_TCP, '<RelTime>', 1)+9
			en  = find_string(DATAREC_UP_TCP, '</RelTime>', pos)
			NowPlay.RelTime = mid_string(DATAREC_UP_TCP, pos, en-pos)
			
			SEND_COMMAND vTP,"'^TXT-401,0,',NowPlay.RelTime"
			SEND_COMMAND vTP,"'^TXT-402,0,',NowPlay.Duration"
			
			RelTimeV= ((TIME_TO_HOUR(NowPlay.RelTime)*3600)+(TIME_TO_MINUTE(NowPlay.RelTime)*60) + TIME_TO_SECOND(NowPlay.RelTime))
			DurationV= ((TIME_TO_HOUR(NowPlay.Duration)*3600)+(TIME_TO_MINUTE(NowPlay.Duration)*60) + TIME_TO_SECOND(NowPlay.Duration))
			
			SEND_COMMAND vTP,"'^GLH-400,',itoa(DurationV)"
			SEND_LEVEL vTP, 400, RelTimeV
			sendUNItext2arr(vTP,403,NowPlay.title)
			sendUNItext2arr(vTP,404,"NowPlay.artist,' - ',NowPlay.album")
			
			
			

			
	}
	
if(find_string(DATAREC_UP_TCP,'GetTransportInfoResponse',1))
	{
	
	
			pos = find_string(DATAREC_UP_TCP, '<CurrentTransportState>', 1)
			en  = find_string(DATAREC_UP_TCP, '</CurrentTransportState>', pos+23)
			if(pos>0) {
			NowPlay.Status = mid_string(DATAREC_UP_TCP, pos+23, en-pos-23)
			}else{
			NowPlay.Status = "''"
			}
			
			[vTP,401]  = (NowPlay.Status=='PLAYING')
			
			
	}
	
}





DEFINE_PROGRAM

wait 10
{
if(ActualSelectPlayer>0) { GetPositionInfo() GetTransportInfo()}
}
