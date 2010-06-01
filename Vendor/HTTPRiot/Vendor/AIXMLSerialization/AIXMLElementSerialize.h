//
//  NSXMLElement+Serialize.h
//  AIXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AIXMLSerialization.h"

@interface NSXMLElement (Serialize)
/**
 * Return this elements attributes as an NSDictionary
 */
- (NSDictionary *)attributesAsDictionary;

/**
 * Transform this NSXMLElement and all of its children to an NSDictionary.
 *
 * Given the XML below:
 * @code
 * <bill session="111" type="hr" number="157" updated="2009-02-14T16:25:06-05:00">
 * 	<status><vote date="1234459620" datetime="2009-02-12T13:27:00-05:00" where="h" result="pass" how="roll" roll="63"/></status>
 *
 * 	<introduced date="1234328400" datetime="2009-02-11"/>
 * 	<titles>
 * 		<title type="official" as="introduced">Providing for consideration of motions to suspend the rules, and for other purposes.</title>
 * 	</titles>
 * 	<sponsor id="412192"/>
 * 	<cosponsors>
 *
 * 	</cosponsors>
 * 	<actions>
 * 		<action date="1234392180" datetime="2009-02-11T18:43:00-05:00"><text>The House Committee on Rules reported an original measure, H. Rept. 111-14, by Mr. Perlmutter.</text></action>
 * 		<action date="1234392180" datetime="2009-02-11T18:43:00-05:00"><text>The resolutions authorizes the Speaker to entertain motions that the House suspend the rules at any time through the legislative day of February 13, 2009. The resolution also provides that the Speaker or her designee shall consult with the Minority Leader or his designee on the designation of any matter for consideration under suspension of the rules pursuant to the resolution. The resolution also provides that H. Res. 10 is amended to change the hour of daily meeting of the House to 9:00 a.m. for Fridays and Saturdays.</text></action>
 * 		<calendar date="1234392240" datetime="2009-02-11T18:44:00-05:00"><text>Placed on the House Calendar, Calendar No. 9.</text></calendar>
 * 		<action date="1234449000" datetime="2009-02-12T10:30:00-05:00"><text>Considered as privileged matter.</text><reference label="consideration" ref="CR H1254-1260"/></action>
 * 		<action date="1234449000" datetime="2009-02-12T10:30:00-05:00"><text>DEBATE - The House proceeded with one hour of debate on H. Res. 157.</text></action>
 * 		<action date="1234452420" datetime="2009-02-12T11:27:00-05:00"><text>The previous question was ordered without objection.</text><reference label="consideration" ref="CR H1260"/></action>
 * 		<action date="1234452420" datetime="2009-02-12T11:27:00-05:00"><text>POSTPONED PROCEEDINGS - At the conclusion of debate on H.Res. 157, the Chair put the question on the agreeing to the resolution, and by voice vote, announced that the ayes had prevailed. Ms. Foxx demanded the yeas and nays and the Chair postponed further proceedings on the resolution until later in the legislative day.</text></action>
 * 		<action date="1234458060" datetime="2009-02-12T13:01:00-05:00"><text>Considered as unfinished business.</text><reference label="consideration" ref="CR H1261"/></action>
 * 		<vote date="1234459620" how="roll" roll="63" datetime="2009-02-12T13:27:00-05:00" where="h" type="vote" result="pass"><text>On agreeing to the resolution Agreed to by the Yeas and Nays: 248 - 174 (Roll no. 63).</text><reference label="text" ref="CR H1255"/></vote>
 * 	</actions>
 * 	<committees>
 * 		<committee name="House Rules" subcommittee="" activity="Origin, Reporting"/>
 * 	</committees>
 * 	<relatedbills>
 * 		<bill relation="unknown" session="111" type="hr" number="10"/>
 * 	</relatedbills>
 * 	<subjects>
 *
 * 	</subjects>
 * 	<amendments>
 *
 * 	</amendments>
 * 	<summary>
 *
 * 	</summary>
 * </bill>
 * @endcode
 *
 * Generates an NSDictionary
 * @code
 *     bill =     {
 *         actions =         {
 *             action =             (
 *                                 {
 *                     date = 1234392180;
 *                     datetime = "2009-02-11T18:43:00-05:00";
 *                     text = "The House Committee on Rules reported an original measure, H. Rept. 111-14, by Mr. Perlmutter.";
 *                 },
 *                                 {
 *                     date = 1234392180;
 *                     datetime = "2009-02-11T18:43:00-05:00";
 *                     text = "The resolutions authorizes the Speaker to entertain motions that the House suspend the rules at any time through the legislative day of February 13, 2009. The resolution also provides that the Speaker or her designee shall consult with the Minority Leader or his designee on the designation of any matter for consideration under suspension of the rules pursuant to the resolution. The resolution also provides that H. Res. 10 is amended to change the hour of daily meeting of the House to 9:00 a.m. for Fridays and Saturdays.";
 *                 },
 *                                 {
 *                     date = 1234449000;
 *                     datetime = "2009-02-12T10:30:00-05:00";
 *                     reference =                     {
 *                         label = consideration;
 *                         ref = "CR H1254-1260";
 *                     };
 *                     text = "Considered as privileged matter.";
 *                 },
 *                                 {
 *                     date = 1234449000;
 *                     datetime = "2009-02-12T10:30:00-05:00";
 *                     text = "DEBATE - The House proceeded with one hour of debate on H. Res. 157.";
 *                 },
 *                                 {
 *                     date = 1234452420;
 *                     datetime = "2009-02-12T11:27:00-05:00";
 *                     reference =                     {
 *                         label = consideration;
 *                         ref = "CR H1260";
 *                     };
 *                     text = "The previous question was ordered without objection.";
 *                 },
 *                                 {
 *                     date = 1234452420;
 *                     datetime = "2009-02-12T11:27:00-05:00";
 *                     text = "POSTPONED PROCEEDINGS - At the conclusion of debate on H.Res. 157, the Chair put the question on the agreeing to the resolution, and by voice vote, announced that the ayes had prevailed. Ms. Foxx demanded the yeas and nays and the Chair postponed further proceedings on the resolution until later in the legislative day.";
 *                 },
 *                                 {
 *                     date = 1234458060;
 *                     datetime = "2009-02-12T13:01:00-05:00";
 *                     reference =                     {
 *                         label = consideration;
 *                         ref = "CR H1261";
 *                     };
 *                     text = "Considered as unfinished business.";
 *                 }
 *             );
 *             calendar =             {
 *                 date = 1234392240;
 *                 datetime = "2009-02-11T18:44:00-05:00";
 *                 text = "Placed on the House Calendar, Calendar No. 9.";
 *             };
 *             vote =             {
 *                 date = 1234459620;
 *                 datetime = "2009-02-12T13:27:00-05:00";
 *                 how = roll;
 *                 reference =                 {
 *                     label = text;
 *                     ref = "CR H1255";
 *                 };
 *                 result = pass;
 *                 roll = 63;
 *                 text = "On agreeing to the resolution Agreed to by the Yeas and Nays: 248 - 174 (Roll no. 63).";
 *                 type = vote;
 *                 where = h;
 *             };
 *         };
 *         amendments =         {
 *         };
 *         committees =         {
 *             committee =             {
 *                 activity = "Origin, Reporting";
 *                 name = "House Rules";
 *                 subcommittee = "";
 *             };
 *         };
 *         cosponsors =         {
 *         };
 *         introduced =         {
 *             date = 1234328400;
 *             datetime = "2009-02-11";
 *         };
 *         number = 157;
 *         relatedbills =         {
 *             bill =             {
 *                 number = 10;
 *                 relation = unknown;
 *                 session = 111;
 *                 type = hr;
 *             };
 *         };
 *         session = 111;
 *         sponsor =         {
 *             id = 412192;
 *         };
 *         status =         {
 *             vote =             {
 *                 date = 1234459620;
 *                 datetime = "2009-02-12T13:27:00-05:00";
 *                 how = roll;
 *                 result = pass;
 *                 roll = 63;
 *                 where = h;
 *             };
 *         };
 *         subjects =         {
 *         };
 *         summary =         {
 *         };
 *         titles =         {
 *             title =             {
 *                 as = introduced;
 *                 content = "Providing for consideration of motions to suspend the rules, and for other purposes.";
 *                 type = official;
 *             };
 *         };
 *         type = hr;
 *         updated = "2009-02-14T16:25:06-05:00";
 *     };
 * }
 * @endcode
 */
- (NSMutableDictionary *)toDictionary;
@end
