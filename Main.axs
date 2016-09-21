/*
UPnP Control point
ORAGECONTROLS S.R.O.
http://www.orangecontrols.cz
Martin Petrasovsky
21.09.2016
*/

PROGRAM_NAME='Main'


DEFINE_DEVICE

	dvUPnPClient	= 0:3:0
	dvUPnPServerMC	= 0:4:0
	`
	TP1 	= 10001:1:0  


//***************************************

DEFINE_VARIABLE

	DEV vTP[ ] = {TP1}
	integer SelUoR
	

//***************************************
#INCLUDE 'UnicodeLib.axi'		
#INCLUDE 'http'	
#INCLUDE 'Upnp'
#INCLUDE 'String'
#INCLUDE 'Radio'
#INCLUDE 'Playlist'
//****************************************


DEFINE_EVENT
button_event[vTP,500]{PUSH:{ LoadPlayListFromDir()}} 

button_event[vTP,551]{PUSH:{ DeletePlayListFromDir(1) }}
button_event[vTP,552]{PUSH:{ DeletePlayListFromDir(2) }}
button_event[vTP,553]{PUSH:{ DeletePlayListFromDir(3) }}
button_event[vTP,554]{PUSH:{ DeletePlayListFromDir(4) }}
button_event[vTP,555]{PUSH:{ DeletePlayListFromDir(5) }}
button_event[vTP,556]{PUSH:{ DeletePlayListFromDir(6) }}
button_event[vTP,557]{PUSH:{ DeletePlayListFromDir(7) }}
button_event[vTP,558]{PUSH:{ DeletePlayListFromDir(8) }}
button_event[vTP,559]{PUSH:{ DeletePlayListFromDir(9) }}
button_event[vTP,560]{PUSH:{ DeletePlayListFromDir(10) }}
button_event[vTP,561]{PUSH:{ DeletePlayListFromDir(11) }}
button_event[vTP,562]{PUSH:{ DeletePlayListFromDir(12) }}
button_event[vTP,563]{PUSH:{ DeletePlayListFromDir(13) }}
button_event[vTP,564]{PUSH:{ DeletePlayListFromDir(14) }}
button_event[vTP,565]{PUSH:{ DeletePlayListFromDir(15) }}
button_event[vTP,566]{PUSH:{ DeletePlayListFromDir(16) }}
button_event[vTP,567]{PUSH:{ DeletePlayListFromDir(17) }}
button_event[vTP,568]{PUSH:{ DeletePlayListFromDir(18) }}
button_event[vTP,569]{PUSH:{ DeletePlayListFromDir(19) }}
button_event[vTP,570]{PUSH:{ DeletePlayListFromDir(20) }}

button_event[vTP,501]{PUSH:{ LoadPlayListFromFile(1) }}
button_event[vTP,502]{PUSH:{ LoadPlayListFromFile(2) }}
button_event[vTP,503]{PUSH:{ LoadPlayListFromFile(3) }}
button_event[vTP,504]{PUSH:{ LoadPlayListFromFile(4) }}
button_event[vTP,505]{PUSH:{ LoadPlayListFromFile(5) }}
button_event[vTP,506]{PUSH:{ LoadPlayListFromFile(6) }}
button_event[vTP,507]{PUSH:{ LoadPlayListFromFile(7) }}
button_event[vTP,508]{PUSH:{ LoadPlayListFromFile(8) }}
button_event[vTP,509]{PUSH:{ LoadPlayListFromFile(9) }}
button_event[vTP,510]{PUSH:{ LoadPlayListFromFile(10) }}
button_event[vTP,511]{PUSH:{ LoadPlayListFromFile(11) }}
button_event[vTP,512]{PUSH:{ LoadPlayListFromFile(12) }}
button_event[vTP,513]{PUSH:{ LoadPlayListFromFile(13) }}
button_event[vTP,514]{PUSH:{ LoadPlayListFromFile(14) }}
button_event[vTP,515]{PUSH:{ LoadPlayListFromFile(15) }}
button_event[vTP,516]{PUSH:{ LoadPlayListFromFile(16) }}
button_event[vTP,517]{PUSH:{ LoadPlayListFromFile(17) }}
button_event[vTP,518]{PUSH:{ LoadPlayListFromFile(18) }}
button_event[vTP,519]{PUSH:{ LoadPlayListFromFile(19) }}
button_event[vTP,520]{PUSH:{ LoadPlayListFromFile(20) }}








button_event[vTP,98]{PUSH:{ HomeBrowse()  SelUoR=0}} //UPnP
button_event[vTP,99]{PUSH:{ GetRadio()  SelUoR=1}} //i Radio

button_event[vTP,100]{PUSH:{ clear_buffer DATAREC_UP  RESET_Browse() RESET_Browse_Player() SEARCH_M() }}//servery

button_event[vTP,101]{PUSH:{ if(SelUoR) {backBrowseRadio()}else{backBrowse()}}}//back

button_event[vTP,102]{PUSH:{ if(SelUoR) {ShowBRupR() }else{ShowBRup()} }}//up
button_event[vTP,103]{PUSH:{ if(SelUoR) {ShowBRdwR() }else{ShowBRdw()} }}//down

button_event[vTP,151]{PUSH:{ ClearPlaylist() }}
button_event[vTP,152]{PUSH:{ ShowPLup() }}//up
button_event[vTP,153]{PUSH:{ ShowPLdw() }}//down

button_event[vTP,1]{PUSH:{ if(SelUoR) {getBrowseRadio(1)}else{getBrowse(1)} } }
button_event[vTP,2]{PUSH:{ if(SelUoR) {getBrowseRadio(2)}else{getBrowse(2)} } }
button_event[vTP,3]{PUSH:{ if(SelUoR) {getBrowseRadio(3)}else{getBrowse(3)} } }
button_event[vTP,4]{PUSH:{ if(SelUoR) {getBrowseRadio(4)}else{getBrowse(4)} } }
button_event[vTP,5]{PUSH:{ if(SelUoR) {getBrowseRadio(5)}else{getBrowse(5)} } }
button_event[vTP,6]{PUSH:{ if(SelUoR) {getBrowseRadio(6)}else{getBrowse(6)} } }
button_event[vTP,7]{PUSH:{ if(SelUoR) {getBrowseRadio(7)}else{getBrowse(7)} } }
button_event[vTP,8]{PUSH:{ if(SelUoR) {getBrowseRadio(8)}else{getBrowse(8)} } }
button_event[vTP,9]{PUSH:{ if(SelUoR) {getBrowseRadio(9)}else{getBrowse(9)} } }
button_event[vTP,10]{PUSH:{ if(SelUoR) {getBrowseRadio(10)}else{getBrowse(10)} }}

button_event[vTP,81]{PUSH:{ RemoveFromPlaylist(1) }}
button_event[vTP,82]{PUSH:{ RemoveFromPlaylist(2) }}
button_event[vTP,83]{PUSH:{ RemoveFromPlaylist(3) }}
button_event[vTP,84]{PUSH:{ RemoveFromPlaylist(4) }}
button_event[vTP,85]{PUSH:{ RemoveFromPlaylist(5) }}
button_event[vTP,86]{PUSH:{ RemoveFromPlaylist(6) }}
button_event[vTP,87]{PUSH:{ RemoveFromPlaylist(7) }}
button_event[vTP,88]{PUSH:{ RemoveFromPlaylist(8) }}
button_event[vTP,89]{PUSH:{ RemoveFromPlaylist(9) }}
button_event[vTP,90]{PUSH:{ RemoveFromPlaylist(10) }}


button_event[vTP,201]{PUSH:{ SelectPlayer(1) }}
button_event[vTP,202]{PUSH:{ SelectPlayer(2) }}
button_event[vTP,203]{PUSH:{ SelectPlayer(3) }}
button_event[vTP,204]{PUSH:{ SelectPlayer(4) }}
button_event[vTP,205]{PUSH:{ SelectPlayer(5) }}
button_event[vTP,206]{PUSH:{ SelectPlayer(6) }}
button_event[vTP,207]{PUSH:{ SelectPlayer(7) }}
button_event[vTP,208]{PUSH:{ SelectPlayer(8) }}
button_event[vTP,209]{PUSH:{ SelectPlayer(9) }}
button_event[vTP,210]{PUSH:{ SelectPlayer(10) }}

button_event[vTP,51]{PUSH:{ SetPlayFromPlayList(1) }}
button_event[vTP,52]{PUSH:{ SetPlayFromPlayList(2) }}
button_event[vTP,53]{PUSH:{ SetPlayFromPlayList(3) }}
button_event[vTP,54]{PUSH:{ SetPlayFromPlayList(4) }}
button_event[vTP,55]{PUSH:{ SetPlayFromPlayList(5) }}
button_event[vTP,56]{PUSH:{ SetPlayFromPlayList(6) }}
button_event[vTP,57]{PUSH:{ SetPlayFromPlayList(7) }}
button_event[vTP,58]{PUSH:{ SetPlayFromPlayList(8) }}
button_event[vTP,59]{PUSH:{ SetPlayFromPlayList(9) }}
button_event[vTP,60]{PUSH:{ SetPlayFromPlayList(10) }}

button_event[vTP,4000]{PUSH:{ ShowPL(a) }}

button_event[vTP,21]{PUSH:{ if(SelUoR) {put2PLr(1)}else{put2PL(1)} }}
button_event[vTP,22]{PUSH:{ if(SelUoR) {put2PLr(2)}else{put2PL(2)} }}
button_event[vTP,23]{PUSH:{ if(SelUoR) {put2PLr(3)}else{put2PL(3)} }}
button_event[vTP,24]{PUSH:{ if(SelUoR) {put2PLr(4)}else{put2PL(4)} }}
button_event[vTP,25]{PUSH:{ if(SelUoR) {put2PLr(5)}else{put2PL(5)} }}
button_event[vTP,26]{PUSH:{ if(SelUoR) {put2PLr(6)}else{put2PL(6)} }}
button_event[vTP,27]{PUSH:{ if(SelUoR) {put2PLr(7)}else{put2PL(7)} }}
button_event[vTP,28]{PUSH:{ if(SelUoR) {put2PLr(8)}else{put2PL(8)} }}
button_event[vTP,29]{PUSH:{ if(SelUoR) {put2PLr(9)}else{put2PL(9)} }}
button_event[vTP,30]{PUSH:{ if(SelUoR) {put2PLr(10)}else{put2PL(10)}}}

button_event[vTP,401] {PUSH:{ if(NowPlay.Status='PLAYING') {SetPause()}else{SetPlay()}}}
level_event[vTP,1] {SetVolume(level.value)}

define_program

wait 1
{
[vTP,98]=( SelUoR==0)
[vTP,99]=( SelUoR==1)
}