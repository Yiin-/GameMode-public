#define format_query( mysql_format(database, query, sizeof query, 

#define min(%0,%1) ((%0)<(%1)?(%0):(%1))
#define max(%0,%1) ((%0)>(%1)?(%0):(%1))

#define F:%0(%1) (format(_@ifb[%0], sizeof _@ifb[], %1), _@ifb[%0])

#define strset strcpy

#if defined INVALID_TEXT_DRAW
	#undef INVALID_TEXT_DRAW
#endif
#define INVALID_TEXT_DRAW (Text:(0xFFFF))
#define INVALID_PLAYER_TEXT_DRAW (PlayerText:(0xFFFF))

/*
 * Static variable initialized once with a non-constant value.
 *
 * Example:
 *   static slots =: GetMaxPlayers();
 */
#define static%1=:%2;  static %1;%1=%2;
#define statix%1=:%2; static %1;{static _@init;if(!_@init){_@init=1;(%1)=%2;}}

/*
 * XYZ0(ar) -> ar[0], ar[1], ar[2]
 *
 * Example:
 *   new Float:pos[3];
 *   GetPlayerPos(playerid, XYZ0(pos));
 */
#define XYZ0(%1)  %1[0],%1[1],%1[2]
#define XYZR0(%1)  %1[0],%1[1],%1[2],%1[3]

/*
 * XYZ0(ar) -> ar[X], ar[Y], ar[Z]
 *
 * Same as above, but for enums with keys X, Y, Z, and optionally Rot.
 */
#define XYZ(%1)  %1[X],%1[Y],%1[Z]
#define XYZR(%1)  %1[X],%1[Y],%1[Z],%1[Rot]

/*
 * Compile-time duration.
 *
 * Example:
 *   DURATION(1 hour, 20 minutes) -> 4800
 */
#define DURATION_MS(%1)     (DURATION(%1) * 1000)
#define DURATION(%1)        (DURATION_PT:%1,0)
#define DURATION_PT:%1,     (%1:DURATION)+_:DURATION_PT:

#define second%1:DURATION
#define seconds%1:DURATION
#define minute%1:DURATION   * DURATION_MINUTE
#define minutes%1:DURATION  * DURATION_MINUTE
#define hour%1:DURATION     * DURATION_HOUR
#define hours%1:DURATION    * DURATION_HOUR
#define day%1:DURATION      * DURATION_DAY
#define days%1:DURATION     * DURATION_DAY
#define week%1:DURATION     * DURATION_WEEK
#define weeks%1:DURATION    * DURATION_WEEK
#define month%1:DURATION    * DURATION_MONTH
#define months%1:DURATION   * DURATION_MONTH
#define year%1:DURATION     * DURATION_YEAR
#define years%1:DURATION    * DURATION_YEAR

/*
 * Shows dialog for a player
 *
 * Shows dialog and resets dialog text buffer.
 */
#define dialogShow(%0) Dialog_ShowCallback(%0); g_DialogText[0] = EOS
#define dialog_Input YSI_g_sDialogCallFix
#define dialog_Row(%0) if(strfind(dialog_Input,%0) != -1)