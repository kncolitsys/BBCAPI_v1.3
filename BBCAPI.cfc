<cfcomponent name="bbc" hint="A CFC wrapper to get information and schedules for programmes on BBC tv and radio channels">

	<cffunction name="init" access="public" returntype="BBCAPI" output="false" hint="I am the constructor method.">
			<!--- holds all private instance data --->
			<cfset variables.stuInstance = StructNew() />
			<cfset variables.stuInstance.apiLocation = 'http://www0.rdthdo.bbc.co.uk/cgi-perl/api/query.pl?' />
		<cfreturn this />		
	</cffunction>
		
	<cffunction name="channelList" output="true" returntype="any" access="public" hint="retrieves the list of channels available through the API">
		<cfset var arrChannelList = ArrayNew(1) />
		<cfset var searchResults = '' />
		<cfset var returnedXML = '' />
		<cfset var channelNodes = '' />
		<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.channel.list&format=simple" />
		<cfset searchResults = "#cfhttp.filecontent#" />
		<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
		<cfset channelNodes = xmlSearch(#searchResults#,'/rsp/channel')>
		<cfif arraylen(channelNodes) GT 0>
			<cfloop from="1" to="#arraylen(channelNodes)#" index="channel">
				<cfset stuChannel = StructNew()>
				<cfset stuChannel.channelid = channelNodes[channel].XMLAttributes.channel_id>
				<cfset stuChannel.name = channelNodes[channel].XMLAttributes.name>
				<!--- get the channel information --->
				<cfset stuChannel.information = getChannelInfo(channelNodes[channel].XMLAttributes.channel_id) />
				<!--- get the channel locations --->
				<cfset stuChannel.locations = getChannelLocations(channelNodes[channel].XMLAttributes.channel_id) />
				<cfset arrayAppend(arrChannelList,stuChannel) />
			</cfloop>
		</cfif>
		<cfreturn arrChannelList />
	</cffunction>
	
	<cffunction name="getChannelInfo" access="public" output="true" returntype="struct" hint="gets information on a specific channel">
		<cfargument name="channelID" required="true" type="string" hint="the unique id for a channel" />
			<cfset var stuChannelInfo = StructNew() />
			<cfset var searchInfoResults = '' />
			<cfset var returnedInfoXML = '' />
			<cfset var channelInfoNodes = '' />
			<cfset var genreNodes = '' />
			<cfset var logoNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.channel.getInfo&channel_id=#arguments.channelID#&format=simple" />
			<cfset searchInfoResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchInfoResults)) />		
			<cfset channelInfoNodes = xmlSearch(#searchInfoResults#,'/rsp/channel')>
			<cfif arraylen(channelInfoNodes) GT 0>
			<cfloop from="1" to="#arraylen(channelInfoNodes)#" index="channel">				
				<cfset genreNodes = xmlSearch(#searchInfoResults#,'/rsp/channel/genre')>
				<cfset arrChannelGenre = ArrayNew(1) />
				<cfif arraylen(genreNodes) GT 0>
				<cfloop from="1" to="#arraylen(genreNodes)#" index="genre">
					<cfset stChannelGenre = StructNew() />
					<cfset stChannelGenre.genreName = genreNodes[genre].XmlAttributes.name />
					<cfset stChannelGenre.genreID = genreNodes[genre].XmlAttributes.genre_id />
					<cfset arrayAppend(arrChannelGenre, stChannelGenre) />
				</cfloop>
				</cfif>
				<cfset stuChannelInfo.genre = arrChannelGenre />
				<cfset logoNodes = xmlSearch(#searchInfoResults#,'/rsp/channel/logo')>
				<cfset arrChannelLogo = ArrayNew(1) />
				<cfif arraylen(logoNodes) GT 0>
				<cfloop from="1" to="#arraylen(logoNodes)#" index="logo">
					<cfset arrChannelLogo[logo] = logoNodes[logo].XmlAttributes />
				</cfloop>
				</cfif>
				<cfset stuChannelInfo.logos = arrChannelLogo />
				<cfset stuChannelInfo.name = channelInfoNodes[channel].XmlAttributes.name />
				<cfset stuChannelInfo.channelID = channelInfoNodes[channel].XmlAttributes.channel_id />
			</cfloop>
			</cfif>
		<cfreturn stuChannelInfo />
	</cffunction>
	
	<cffunction name="getChannelLocations" access="public" output="true" returntype="array">
		<cfargument name="channelID" required="true" type="string" hint="the unique id for a channel" />
			<cfset var arrChannelLoc = ArrayNew(1) />
			<cfset var searchInfoResults = '' />
			<cfset var returnedInfoXML = '' />
			<cfset var channelLocNodes = '' />
			<cfset var genreNodes = '' />
			<cfset var logoNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.channel.getLocations&channel_id=#arguments.channelID#&format=simple" />
			<cfset searchInfoResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchInfoResults)) />			
			<cfset channelLocNodes = xmlSearch(#searchInfoResults#,'/rsp/channel/location')>
			<cfif arraylen(channelLocNodes) GT 0>
				<cfloop from="1" to="#arraylen(channelLocNodes)#" index="location">	
					<cfset stuChannelLoc = StructNew() />
					<cfset stuChannelLoc.locationURL = channelLocNodes[location].url.XmlText />
					<cfset stuChannelLoc.locationType = channelLocNodes[location].type.XmlText />
					<cfset arrayAppend(arrChannelLoc,stuChannelLoc) />
				</cfloop>
			</cfif>
		<cfreturn arrChannelLoc />
	</cffunction>
	
	
	<!--- Genre specific functions --->
		
	<cffunction name="getGenreList" output="true" returntype="any" access="public" hint="gets a list of all available genres">
		<cfset var arrGenreList = ArrayNew(1) />
		<cfset var searchResults = '' />
		<cfset var returnedXML = '' />
		<cfset var genreNodes = '' />
		<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.genre.list&format=simple" />
		<cfset searchResults = "#cfhttp.filecontent#" />
		<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
		<cfset genreNodes = xmlSearch(#searchResults#,'/rsp/genre')>
		<cfif arraylen(genreNodes) GT 0>
			<cfloop from="1" to="#arraylen(genreNodes)#" index="genre">
				<cfset arrayAppend(arrGenreList,genreNodes[genre].XMLAttributes) />
			</cfloop>
		</cfif>
		<cfreturn arrGenreList />
	</cffunction>
	
	<cffunction name="getGenreMembers" output="true" returntype="any" access="public" hint="gets all members of a specific genre">
		<cfargument name="genreID" required="yes" type="string" hint="the unique id for a genre" />
			<cfset var arrGenreList = ArrayNew(1) />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var genreNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.genre.getMembers&genre_id=#arguments.genreID#&format=simple" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfset genreNodes = xmlSearch(#searchResults#,'/rsp/genre/programme')>
			<cfif arraylen(genreNodes) GT 0>
				<cfloop from="1" to="#arraylen(genreNodes)#" index="programme">
					<cfset genreProg = StructNew() />
					<cfset genreProg.programmeID = genreNodes[programme].XmlAttributes.programme_id />
					<cfset genreProg.title = genreNodes[programme].XmlAttributes.title />
					<cfset arrayAppend(arrGenreList,genreProg) />
				</cfloop>
			</cfif>
		<cfreturn arrGenreList />
	</cffunction>
	
	<!--- end of Genre functions --->
	
	<!--- Programme specific functions --->
	
	<cffunction name="getProgrammeSchedule" output="true" returntype="any" access="public" hint="gets the schedule for a specific channel">
		<cfargument name="channelID" required="true" type="string" hint="the unique id for a channel" />
		<cfargument name="startDate" required="no" type="string" default="#DateFormat(Now(), "yyyy-mm-dd")#T#TimeFormat(Now(), "HH:MM:SS")#Z" hint="the start date for the schedule search" />
		<cfargument name="endDate" required="no" type="string" default="#DateFormat(Now(), "yyyy-mm-dd")#T23:59:59Z" hint="the end date for the schedule search" />
		<cfargument name="limit" required="no" type="numeric" default="50" hint="the maximum results you want returned" />
		<cfargument name="detail" required="false" type="string" default="schedule" hint="the level of detail returned" />
			<cfset var arrScheduleList = ArrayNew(1) />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var programmeNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.schedule.getProgrammes&channel_id=#arguments.channelID#&start=#arguments.startDate#&end=#arguments.endDate#&limit=#arguments.limit#&detail=#arguments.detail#" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfset programmeNodes = xmlSearch(#searchResults#,'/rsp/schedule/programme')>
			<cfif arraylen(programmeNodes) GT 0>
			<cfloop from="1" to="#arraylen(programmeNodes)#" index="programme">	
				<cfset stuProgramme = StructNew() />
				<cfset stuProgramme.name = programmeNodes[programme].XmlAttributes.title />
				<cfset stuProgramme.progID = programmeNodes[programme].XmlAttributes.programme_id />
				<cfset stuProgramme.synopsis = programmeNodes[programme].synopsis.XmlText />
				<cfset stuProgramme.channelID = programmeNodes[programme].channel_id.XmlText />
				<cfset stuProgramme.start = programmeNodes[programme].start.XmlText />
				<cfset stuProgramme.duration = programmeNodes[programme].duration.XmlText />
				<cfset arrayAppend(arrScheduleList,stuProgramme) />
			</cfloop>
			</cfif>
			<cfset stuSchedule = StructNew() />
			<cfset stuSchedule.channelInfo = getChannelInfo(arguments.channelID)>
			<cfset stuSchedule.schedule = arrScheduleList />
		<cfreturn stuSchedule />
	</cffunction>
	
	<cffunction name="getProgrammeInfo" output="true" returntype="any" access="public" hint="gets information for a specific programme">
		<cfargument name="programmeID" required="yes" type="string" hint="the unique id for a programme" />
			<cfset var stuProg = StructNew() />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var programmeNodes = '' />
			<cfset var eventNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.programme.getInfo&programme_id=#arguments.programmeID#&format=simple" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfset programmeNodes = xmlSearch(#searchResults#,'/rsp/programme')>
			<cfif arraylen(programmeNodes) GT 0>
				<cfloop from="1" to="#arraylen(programmeNodes)#" index="programme">
					<cfset stuProg.programmeID = programmeNodes[programme].XmlAttributes.programme_id />
					<cfset stuProg.name = programmeNodes[programme].XmlAttributes.title />
					<cfset stuProg.synopsis = programmeNodes[programme].synopsis.XmlText />
					<!--- get programme locations --->
					<cfset stuProg.locations = getProgrammeLocations(arguments.programmeID) />
					<cfset eventNodes = xmlSearch(#searchResults#,'/rsp/programme/event')>
					<cfset arrEventList = ArrayNew(1) />
					<cfif arraylen(eventNodes) GT 0>
					<cfloop from="1" to="#arraylen(eventNodes)#" index="event">
						<cfset stuEvent = StructNew() />
						<cfset stuEvent.channelID = eventNodes[event].XmlAttributes.channel_id />
						<cfset stuEvent.channelInfo = getChannelInfo(eventNodes[event].XmlAttributes.channel_id) />
						<cfset stuEvent.start = eventNodes[event].start.XmlText />
						<cfset stuEvent.duration = eventNodes[event].duration.XmlText />
						<cfset arrayAppend(arrEventList,stuEvent) />
					</cfloop>
					</cfif>
					<cfset stuProg.events = arrEventList />
					<cfset genreNodes = xmlSearch(#searchResults#,'/rsp/programme/genre')>
					<cfset arrGenreList = ArrayNew(1) />
					<cfif arraylen(genreNodes) GT 0>
					<cfloop from="1" to="#arraylen(genreNodes)#" index="genre">
						<cfset stuGenre = StructNew() />
						<cfset stuGenre.genreID = genreNodes[genre].XmlAttributes.genre_id />
						<cfset stuGenre.name = genreNodes[genre].XmlText />
						<cfset arrayAppend(arrGenreList,stuGenre) />
					</cfloop>
					</cfif>
					<cfset stuProg.genre = arrGenreList />
					<cfset groupNodes = xmlSearch(#searchResults#,'/rsp/programme/group')>
					<cfset arrGroupList = ArrayNew(1) />
					<cfif arraylen(groupNodes) GT 0>
					<cfloop from="1" to="#arraylen(groupNodes)#" index="group">
						<cfset stuGroup = StructNew() />
						<cfset stuGroup.groupID = groupNodes[group].XmlAttributes.group_id />
						<cfset stuGroup.name = groupNodes[group].XmlText />
						<cfset arrayAppend(arrGroupList,stuGroup) />
					</cfloop>
					</cfif>
					<cfset stuProg.group = arrGroupList />
				</cfloop>
			</cfif>
		<cfreturn stuProg />
	</cffunction>
	
	<cffunction name="getProgrammeLocations" access="public" output="true" returntype="struct" hint="gets details on programme locations">
		<cfargument name="programmeID" required="true" type="string" hint="the unique id for a programme" />
			<cfset var arrChannelLoc = ArrayNew(1) />
			<cfset var searchInfoResults = '' />
			<cfset var returnedInfoXML = '' />
			<cfset var programmeLocNodes = '' />
			<cfset var genreNodes = '' />
			<cfset var logoNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.programme.getLocations&programme_id=#arguments.programmeID#&format=simple" />
			<cfset searchInfoResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchInfoResults)) />	
			<cfset programmeLocNodes = xmlSearch(#searchInfoResults#,'/rsp/programme/location')>
			<cfif arraylen(programmeLocNodes) GT 0>
				<cfloop from="1" to="#arraylen(programmeLocNodes)#" index="location">	
					<cfset stuChannelLoc = StructNew() />
					<cfset stuChannelLoc.locationURL = programmeLocNodes[location].url.XmlText />
					<cfset stuChannelLoc.locationType = programmeLocNodes[location].type.XmlText />
					<cfset stuChannelLoc.duration = programmeLocNodes[location].duration.XmlText />
					<cfset stuChannelLoc.start = programmeLocNodes[location].start.XmlText />
					<cfset arrayAppend(arrChannelLoc,stuChannelLoc) />
				</cfloop>
			</cfif>
			<cfset stuProgrammeInfo = StructNew() />
			<cfset stuProgrammeInfo.locationDetails = arrChannelLoc />
		<cfreturn stuProgrammeInfo />
	</cffunction>
	
	<cffunction name="programmeSearch" output="true" returntype="any" access="public" hint="searches the API for programmes, based upon keywords supplied">
		<cfargument name="title" required="yes" type="string" hint="the title keywords you wish to include in the search" />
			<cfset var arrMembersList = ArrayNew(1) />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var groupNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.programme.search&title_id=#trim(arguments.title)#&format=simple" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfdump var="#returnedXML#">
	</cffunction>
	<!--- end of Programme functions --->
	
	<!--- Group specific functions --->
	
	<cffunction name="getGroupList" output="true" returntype="any" access="public" hint="gets a list of all groups available within the API">
		<cfset var arrGroupList = ArrayNew(1) />
		<cfset var searchResults = '' />
		<cfset var returnedXML = '' />
		<cfset var groupNodes = '' />
		<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.group.list&format=simple" />
		<cfset searchResults = "#cfhttp.filecontent#" />
		<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
		<cfset groupNodes = xmlSearch(#searchResults#,'/rsp/group')>
		<cfif arraylen(groupNodes) GT 0>
			<cfloop from="1" to="#arraylen(groupNodes)#" index="group">
				<cfset stuGroup = StructNew() />
				<cfset stuGroup.groupID = groupNodes[group].XmlAttributes.group_id />
				<cfset stuGroup.name = groupNodes[group].XmlAttributes.title />
				<cfset arrayAppend(arrGroupList,stuGroup) />
			</cfloop>
		</cfif>
		<cfreturn arrGroupList />
	</cffunction>
	
	<cffunction name="getGroupInfo" output="true" returntype="any" access="public" hint="gets information for a specific group">
		<cfargument name="groupID" required="yes" type="string" hint="the unique id for a group" />
			<cfset var arrMembersList = ArrayNew(1) />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var groupNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.group.getInfo&group_id=#arguments.groupID#&format=simple" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfset groupNodes = xmlSearch(#searchResults#,'/rsp/group')>
			<cfif arraylen(groupNodes) GT 0>
				<cfloop from="1" to="#arraylen(groupNodes)#" index="group">
					<cfset stuGroup = StructNew() />
					<cfset stuGroup.groupID = groupNodes[group].XmlAttributes.group_id />
					<cfset stuGroup.name = groupNodes[group].XmlAttributes.title />
					<cfset stuGroup.synopsis = groupNodes[group].synopsis.XmlText />
					<cfset stuGroup.type = groupNodes[group].type.XmlText />
					<cfset arrayAppend(arrMembersList,stuGroup) />
				</cfloop>
			</cfif>
		<cfreturn arrMembersList />
	</cffunction>
	
	<cffunction name="groupMembersList" output="true" returntype="any" access="public" hint="gets members of a specific group">
		<cfargument name="groupID" required="yes" type="string" hint="the unique id for a group" />
			<cfset var arrMembersList = ArrayNew(1) />
			<cfset var searchResults = '' />
			<cfset var returnedXML = '' />
			<cfset var groupNodes = '' />
			<cfhttp url="#variables.stuInstance.apiLocation#method=bbc.group.getMembers&group_id=#arguments.groupID#&format=simple" />
			<cfset searchResults = "#cfhttp.filecontent#" />
			<cfset returnedXML = XmlParse(xmlStrip(searchResults)) />
			<cfset groupNodes = xmlSearch(#searchResults#,'/rsp/group/programme')>
			<cfif arraylen(groupNodes) GT 0>
				<cfloop from="1" to="#arraylen(groupNodes)#" index="group">
					<cfset stuGroup = StructNew() />
					<cfset stuGroup.programmeID = groupNodes[group].XmlAttributes.programme_id />
					<cfset stuGroup.name = groupNodes[group].XmlAttributes.title />
					<cfset arrayAppend(arrMembersList,stuGroup) />
				</cfloop>
			</cfif>
		<cfreturn arrMembersList />
	</cffunction>
	
	<cffunction name="xmlStrip" access="public" returntype="xml" output="true" hint="I help with stripping out tags and tidying up the returned XML">
		<cfargument name="xmlIn" required="true" type="xml" hint="the XML retrieved from the CFHTTP request" />
			<cfset var originalXML = arguments.xmlIn />
			<!--- Strip out the tag prefixes. This will convert tags from the form of soap:nodeName to JUST nodeName. This works for both opening and closing tags. --->
			<cfset xmlOut = originalXML.ReplaceAll("(</?)(\w+:)","$1") />
			<!--- Remove all references to XML name spaces. These are node attributes that begin with "xmlns:". --->
			<cfset xmlOut = xmlOut.ReplaceAll("xmlns(:\w+)?=""[^""]*""","") />
		<cfreturn xmlOut />
	</cffunction>	
	
</cfcomponent>