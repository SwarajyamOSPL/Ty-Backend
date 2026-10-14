--
-- PostgreSQL database dump
--

\restrict aMOpmlp4DmSPPkJK8LD0ELdzVBPfZdJafAipM4h9YhEByEBeyHgrnv9nExTcdml

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: partykind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.partykind AS ENUM (
    'partner',
    'capper'
);


ALTER TYPE public.partykind OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_websites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_websites (
    id integer NOT NULL,
    account_id integer NOT NULL,
    website character varying(255) NOT NULL
);


ALTER TABLE public.account_websites OWNER TO postgres;

--
-- Name: account_websites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_websites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.account_websites_id_seq OWNER TO postgres;

--
-- Name: account_websites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_websites_id_seq OWNED BY public.account_websites.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    username character varying(255),
    password_enc text,
    balance numeric(14,2),
    max_win numeric(14,2),
    city character varying(255),
    created_at timestamp with time zone NOT NULL,
    balance_text character varying(100),
    max_win_text character varying(100)
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounts_id_seq OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: admin_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_credentials (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    CONSTRAINT single_admin CHECK ((id = 1))
);


ALTER TABLE public.admin_credentials OWNER TO postgres;

--
-- Name: figures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.figures (
    id integer NOT NULL,
    party_id integer NOT NULL,
    account_id integer NOT NULL,
    figure numeric(14,2) NOT NULL,
    figure_date date NOT NULL,
    start_date date,
    end_date date,
    entered_by integer,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.figures OWNER TO postgres;

--
-- Name: figures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.figures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.figures_id_seq OWNER TO postgres;

--
-- Name: figures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.figures_id_seq OWNED BY public.figures.id;


--
-- Name: parties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parties (
    id integer NOT NULL,
    kind public.partykind NOT NULL,
    name character varying(255) NOT NULL,
    name_key character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.parties OWNER TO postgres;

--
-- Name: parties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.parties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parties_id_seq OWNER TO postgres;

--
-- Name: parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.parties_id_seq OWNED BY public.parties.id;


--
-- Name: party_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.party_accounts (
    id integer NOT NULL,
    party_id integer NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.party_accounts OWNER TO postgres;

--
-- Name: party_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.party_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.party_accounts_id_seq OWNER TO postgres;

--
-- Name: party_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.party_accounts_id_seq OWNED BY public.party_accounts.id;


--
-- Name: site_figures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_figures (
    id integer NOT NULL,
    account_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    site_figure numeric(14,2) NOT NULL,
    calculated_by integer,
    calculated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.site_figures OWNER TO postgres;

--
-- Name: site_figures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.site_figures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.site_figures_id_seq OWNER TO postgres;

--
-- Name: site_figures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.site_figures_id_seq OWNED BY public.site_figures.id;


--
-- Name: account_websites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_websites ALTER COLUMN id SET DEFAULT nextval('public.account_websites_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: figures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.figures ALTER COLUMN id SET DEFAULT nextval('public.figures_id_seq'::regclass);


--
-- Name: parties id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parties ALTER COLUMN id SET DEFAULT nextval('public.parties_id_seq'::regclass);


--
-- Name: party_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.party_accounts ALTER COLUMN id SET DEFAULT nextval('public.party_accounts_id_seq'::regclass);


--
-- Name: site_figures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_figures ALTER COLUMN id SET DEFAULT nextval('public.site_figures_id_seq'::regclass);


--
-- Data for Name: account_websites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_websites (id, account_id, website) FROM stdin;
1	1	betbuckeyesports.com
2	2	Square999.com
3	3	Square999.com
4	4	Bettingzoo.ag
5	5	Betdph.com
6	6	Bettorprice.com
7	7	Bettorprice.com
8	8	Bettorprice.com
9	9	bluecoins.ag
10	10	Wagershack.com
11	11	Ezplay2001.com
12	12	Square999.com
13	13	Square999.com
14	14	Square999.com
15	15	Square999.com
16	16	Dailysports365.com
17	17	Bestbets.vip
18	18	Bestbets.vip
19	19	Bestbets.vip
20	20	Bestbets.vip
21	21	Bestbets.vip
22	22	Bestbets.vip
23	23	Bestbets.vip
24	24	Bestbets.vip
25	25	Bestbets.vip
26	26	Bestbets.vip
27	27	Bestbets.vip
28	28	Bestbets.vip
29	29	Bestbets.vip
30	30	Bestbets.vip
31	31	Bestbets.vip
32	32	Bestbets.vip
33	33	Bestbets.vip
34	34	Bestbets.vip
35	35	Bestbets.vip
36	36	Bestbets.vip
37	37	Bestbets.vip
38	38	Bestbets.vip
39	39	Bestbets.vip
40	40	Bestbets.vip
41	41	Bestbets.vip
42	42	Bestbets.vip
43	43	Bestbets.vip
44	44	Bestbets.vip
45	45	Bestbets.vip
46	46	Bestbets.vip
47	47	Bestbets.vip
48	48	Playbetnow.com
49	49	betwindycity.com
50	50	Bettingzoo.com
51	51	Sunwager.com
52	52	elitesports.now
53	53	elitesports.now
54	54	Crazywager247.com
55	55	Hsb55.com
56	56	Bluecoins.ag
57	57	Betbigcity.ag
58	58	overtime.ag
59	59	Platinumsportz.com
60	60	trylnk.com
61	61	333locks.com
62	62	Actionbets.ag
63	63	vip365.ag
64	64	vip365.ag
65	65	purewage.com
66	66	wagerhouse.ag
67	67	nextplay24.com
68	68	Wagershack.com
69	69	empire.ag
70	70	Loxandspreads.com
71	71	Jwsportsinfo.com
72	72	Loxandspreads.com
73	73	betbuckeyesports.com
74	74	slick247.com
75	75	goldbook.ag
76	76	Bestbets.vip
77	77	Bestbets.vip
78	78	Bestbets.vip
79	79	Bestbets.vip
80	80	Bestbets.vip
81	81	gameday777.com
82	82	Bone.ag
83	83	Playbetnow.com
84	84	Sunwager.com
85	85	sportingnews.life
86	86	Bestbets.vip
87	87	Play23.ag
88	88	rizzbets.ag
89	89	Probooknyc.com
90	90	Betfastaction.ag
91	91	Rum88.com
92	92	betvip247.net
93	93	anybet365.com
94	94	Ez3388.ag
95	95	Ez3388.ag
96	96	Ez3388.ag
97	97	win88.ag
98	98	play23.ag
99	99	sonic66.com
100	100	be77.net
101	101	Betfan88.com
102	102	gameon39.com
103	103	Pis.ag
104	104	pick7s.com
105	105	pick7s.com
106	106	pick7s.com
107	107	pick7s.com
108	108	Pick7s.com
109	109	Pick7s.com
110	110	gameon39.com
111	111	Abcodds.com
112	112	Tigertd.com
113	113	Tigertd.com
114	114	win88.ag
115	115	bettingzoo.ag
116	116	369bets.com
117	117	369bets.com
118	118	369bets.com
119	119	369bets.com
120	120	369bets.com
121	121	Phobolsa39.com
122	122	livebet88.eu
123	123	livebet88.eu
124	124	livebet88.eu
125	125	black702.com
126	126	diamondsb.com
127	127	diamondsb.com
128	128	diamondsb.com
129	129	diamondsb.com
130	130	diamondsb.com
131	131	diamondsb.com
132	132	diamondsb.com
133	133	diamondsb.com
134	134	diamondsb.com
135	135	diamondsb.com
136	136	diamondsb.com
137	137	diamondsb.com
138	138	diamondsb.com
139	139	diamondsb.com
140	140	diamondsb.com
141	141	diamondsb.com
142	142	diamondsb.com
143	143	diamondsb.com
144	144	diamondsb.com
145	145	ezplay247.com
146	146	ezplay247.com
147	147	ezplay247.com
148	148	ezplay247.com
149	149	ezplay247.com
150	150	ezplay247.com
151	151	ezplay247.com
152	152	ezplay247.com
153	153	ezplay247.com
154	154	ezplay247.com
155	155	ezplay247.com
156	156	ezplay247.com
161	161	leftcoast797.com
166	166	Smash66.com
171	171	Liveactionbets.com
157	157	ezplay247.com
162	162	leftcoast797.com
167	167	5racks.com
158	158	leftcoast797.com
163	163	leftcoast797.com
168	168	5racks.com
159	159	leftcoast797.com
164	164	leftcoast797.com
169	169	5racks.com
160	160	leftcoast797.com
165	165	leftcoast797.com
170	170	5racks.com
172	172	Picks25.com
173	173	Picks25.com
174	174	Picks25.com
175	175	diamondsb.com
176	176	trylnk.com
177	177	333locks.com
178	178	Overtime.ag
179	179	Skullbet.com
180	180	Picks25.com
181	181	wcsports1.com
182	182	Diamondsb.com
183	183	Diamondsb.com
184	184	ezplay247.com
185	185	Leftcoast797.com
186	186	Leftcoast797.com
187	187	Aceshigh.ag
188	188	Bone.ag
189	189	Bone.ag
190	190	vip365.ag
191	191	bluebird00.com
192	192	goldbook.ag
193	193	8plays.com
194	194	play305.com
195	195	thewagerguys.com
196	196	yoursportsbetting.com
197	197	5starwagerz.com
198	198	Winwager.eu
199	199	betvegas777.com
200	200	Play23.ag
201	201	Betfastaction.ag
202	202	Vip365.ag
203	203	Wagershack.com
204	204	Sweatcity.ag
205	205	action527.com
206	206	EC-Investor.com
207	207	legacy365.net
208	208	legacy365.net
209	209	actionbets.com
210	210	Sportscappers.io
211	211	Sportscappers.io
212	212	Sportscappers.io
213	213	Sportscappers.io
214	214	Thevault.ag
215	215	woopig.io
216	216	Sportscappers.io
217	217	Sportscappers.io
218	218	Sundaytilt.com
219	219	888east.com
220	220	Wagerpalace.ag
221	221	BESTBETS.VIP
222	222	red409.com
223	223	red409.com
224	224	Bestbets.vip
225	225	Bestbets.vip
226	226	Bestbets.vip
227	227	Bestbets.vip
228	228	Aceshigh.ag
229	229	Aceshigh.ag
230	230	Aceshigh.ag
231	231	Aceshigh.ag
232	232	Aceshigh.ag
233	233	cherrybet.ag
234	234	aceshigh.ag
235	235	gobetya.net
236	236	Square999.com
237	237	Square999.com
238	238	betnow187.com
239	239	Ec-investor.com
240	240	dragon17.com
241	241	texas55.com
242	242	texas55.com
243	243	texas55.com
244	244	sportscappers.io
245	245	Bettingzoo.ag
246	246	Sunwager.com
247	247	Sunwager.com
248	248	Sportsmans-lounge.com
249	249	Sportsmans-lounge.com
250	250	Sportsmans-lounge.com
251	251	Sportsmans-lounge.com
252	252	Sonic66.com
253	253	Buzzerbeater.ag
254	254	Sun22.ag
255	255	Square999.com
256	256	Crashsb.com
257	257	Axenlight.com
258	258	Axenlight.com
259	259	fantasy702.com
260	260	333locks.com
261	261	actionpro.io
262	262	Betempire.ag
263	263	play23.ag
264	264	betselite.com
265	265	betselite.com
266	266	luckypanda.ag
267	267	play47.com
268	268	Green909.com
269	269	betallstar.ag
270	270	betallstar.ag
271	271	mks888.com
272	272	eag.ag
273	273	eag.ag
274	274	gameday.ag
275	275	blitzbet.io
276	276	elitesports.now
277	277	c2cbets.ag
278	278	c2cbets.ag
279	279	247lines.com
280	280	Betemnow.com
281	281	Betemnow.com
282	282	Platinumsportz.com
283	283	Maxplay.ag
284	284	Onemorebet.com
285	285	Bet888.ag
286	286	Housesports77.com
287	287	Play23.live
288	288	Fastaction88.com
289	289	Yopig.ag
290	290	Spwagers.com
291	291	77silver.com
292	292	77silver.com
293	293	Lonestar28.com
294	294	Lonestar28.com
295	295	Lonestar28.com
296	296	Lonestar28.com
297	297	Fire22.com
298	298	Fire22.com
299	299	elitesports.now
300	300	Betsafe777.net
301	301	Red409.com
302	302	Rum88.com
303	303	Rum88.com
304	304	Rum88.com
305	305	Rum88.com
306	306	Sunwager.com
307	307	Sunwager.com
308	308	Sunwager.com
309	309	Sunwager.com
310	310	Sunwager.com
311	311	Sunwager.com
312	312	Sunwager.com
313	313	Sunwager.com
314	314	Sunwager.com
315	315	Sunwager.com
316	316	Sunwager.com
317	317	Sunwager.com
318	318	Sunwager.com
319	319	Sunwager.com
320	320	Sunwager.com
321	321	Sunwager.com
322	322	Sunwager.com
323	323	Hsb55.com
328	328	Queenofspades.live
333	333	Solidout360.com
338	338	betfastaction.ag
343	343	Fire22.com
348	348	Lionwager.com
353	353	Highrollers409.com
358	358	Tigertd.com
363	363	Bombay711.com
368	368	Goldbook.ag
373	373	Goldbook.ag
378	378	Sunwager.com
383	383	Bettingzoo.ag
388	388	Bettingzoo.ag
393	393	Odds2wager.com
398	398	Bombay711.com
403	403	betcatalinasports.com
408	408	Bettingzoo.ag
413	413	Rum88.com
418	418	Rum88.com
423	423	housesports77.com
428	428	ibet.ag
433	433	Bettorlock.com
438	438	Goldbook.ag
443	443	Sunwager.com
448	448	Sunwager.com
453	453	Sunwager.com
458	458	Sunwager.com
463	463	Lonestar28.com
468	468	Red409.com
473	473	Betplayboys.ag
478	478	Bettingzoo.ag
483	483	Lionwager.com
488	488	Lionwager.com
493	493	2bettvs.com
498	498	eag.ag
503	503	Rygbyrex.com
508	508	Bombay711.com
513	513	Highrollers409.com
518	518	xpressplays.com
523	523	Odds2wager.com
528	528	playcr.ag
533	533	Phoenix22.com
538	538	77silver.com
543	543	diamondsb.ag
548	548	Mastermindbets.com
553	553	Outtaspaceplays.com
558	558	action247.ag
563	563	Bettingzoo.ag
324	324	Hsb55.com
329	329	falcon.ag
334	334	2x2wagers.com
339	339	Fire22.com
344	344	Lionwager.com
349	349	Lionwager.com
354	354	Xutu.ag
359	359	Tigertd.com
364	364	Goldbook.ag
369	369	Goldbook.ag
374	374	Goldbook.ag
379	379	Sunwager.com
384	384	Bettingzoo.ag
389	389	Spwagers.com
394	394	Bombay711.com
399	399	gameday.ag
404	404	bettingzoo.ag
409	409	Bettingzoo.ag
414	414	Rum88.com
419	419	Rum88.com
424	424	ezplay247.com
429	429	playnow365.com
434	434	tigertd.com
439	439	Sunwager.com
444	444	Sunwager.com
449	449	Sunwager.com
454	454	Sunwager.com
459	459	Sunwager.com
464	464	Lonestar28.com
469	469	Red409.com
474	474	betsoffshore.io
479	479	77silver.com
484	484	Lionwager.com
489	489	Betthechamp.com
494	494	vaultwagers.com
499	499	Betvegas777.com
504	504	silver707.com
509	509	Wagershack.com
514	514	Superbook888.com
519	519	Betvipsports.com
524	524	Bluecoins.ag
529	529	333locks.com
534	534	Bigwave99.com
539	539	77silver.com
544	544	betvegas23.ag
549	549	betwar.com
554	554	blackpointsb.com
559	559	Square999.com
564	564	dontbackupstackup.com
325	325	Black99.net
330	330	Crazywager247.com
335	335	2x2wagers.com
340	340	Fire22.com
345	345	Lionwager.com
350	350	Lionwager.com
355	355	Xutu.ag
360	360	Tigertd.com
365	365	Goldbook.ag
370	370	Goldbook.ag
375	375	Goldbook.ag
380	380	Sunwager.com
385	385	Bettingzoo.ag
390	390	Saber77.com
395	395	Bombay711.com
400	400	betcatalinasports.com
405	405	bettingzoo.ag
410	410	Betemnow.com
415	415	Rum88.com
420	420	Crazywager247.com
425	425	Monkeywager.com
430	430	playnow365.com
435	435	Bettingzoo.ag
440	440	Sunwager.com
445	445	Sunwager.com
450	450	Sunwager.com
455	455	Bombay711.com
460	460	Sunwager.com
465	465	Lonestar28.com
470	470	Goldbook.ag
475	475	Bettingzoo.ag
480	480	Fire22.com
485	485	Lionwager.com
490	490	Betthechamp.com
495	495	blue42.pro
500	500	Betvegas23.com
505	505	Bombay711.com
510	510	Riskthefarm.com
515	515	Spwagers.com
520	520	Sbplay.com
525	525	maxplay.ag
530	530	333locks.com
535	535	Steam22.com
540	540	Rum88.com
545	545	betfastaction.ag
550	550	2x2wagers.com
555	555	77silver.com
560	560	Falcon.ag
326	326	Platinumsportz.com
331	331	Crazywager247.com
336	336	2x2wagers.com
341	341	Fire22.com
346	346	23platinum.com
351	351	Lionwager.com
356	356	Xutu.ag
361	361	Wagershack.com
366	366	Goldbook.ag
371	371	Goldbook.ag
376	376	probet365.co
381	381	Sunwager.com
386	386	Bettingzoo.ag
391	391	Properbets.io
396	396	Bombay711.com
401	401	betcatalinasports.com
406	406	Bettingzoo.ag
411	411	Lionwager.com
416	416	Rum88.com
421	421	Crazywager247.com
426	426	wagersus5.com
431	431	pgwsports.com
436	436	Bettingzoo.ag
441	441	Sunwager.com
446	446	Sunwager.com
451	451	Sunwager.com
456	456	Sunwager.com
461	461	Sunwager.com
466	466	Lonestar28.com
471	471	Blue678.com
476	476	Bettingzoo.ag
481	481	Fire22.com
486	486	Lionwager.com
491	491	Betthechamp.com
496	496	black99.net
501	501	Betvegas23.com
506	506	Bombay711.com
511	511	Rukes42.com
516	516	Spwagers.com
521	521	ezplay247.com
526	526	ocbet.ag
531	531	333locks.com
536	536	black88.vip
541	541	Rum88.com
546	546	betfastaction.ag
551	551	Playbig777.com
556	556	77silver.com
561	561	Livewager247.com
327	327	Coinaction.ag
332	332	Lion44.com
337	337	betfastaction.ag
342	342	Fire22.com
347	347	Lionwager.com
352	352	Lionwager.com
357	357	Tigertd.com
362	362	Bombay711.com
367	367	Goldbook.ag
372	372	Goldbook.ag
377	377	Betbuckeyesports.com
382	382	Sunwager.com
387	387	Bettingzoo.ag
392	392	Sportsplay2.com
397	397	Bombay711.com
402	402	betcatalinasports.com
407	407	Bettingzoo.ag
412	412	Lionwager.com
417	417	Rum88.com
422	422	Crazywager247.com
427	427	Maxplay.ag
432	432	Wisewager13.com
437	437	Goldbook.ag
442	442	Sunwager.com
447	447	Sunwager.com
452	452	Sunwager.com
457	457	Sunwager.com
462	462	Lonestar28.com
467	467	Lonestar28.com
472	472	Goldbook.ag
477	477	Bettingzoo.ag
482	482	Lionwager.com
487	487	Lionwager.com
492	492	Betthechamp.com
497	497	eag.ag
502	502	Betvegas23.com
507	507	Bombay711.com
512	512	c2cbets.ag
517	517	Spwagers.com
522	522	primeplays53.com
527	527	Mvpqb.com
532	532	onemorebet.com
537	537	ocbet.ag
542	542	Rum88.com
547	547	readyforgamble.com
552	552	2x2wagers.com
557	557	action247.ag
562	562	sonic66.com
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (id, username, password_enc, balance, max_win, city, created_at, balance_text, max_win_text) FROM stdin;
1	Yng101	gAAAAABqzhr4wf_aLnogULu5fwuZGgYqYKVeFLan1QDPtphFaLgnFu7kPz8THGYsLfMkzGosIXkKvbM9tW2_T1cXfZ5vREFy9w==	5000.00	\N	\N	2026-10-13 17:20:16.526231+05:30	\N	\N
2	Mg25	gAAAAABqzhr47cTBaZzJsi3C8uj1ECgczS15EA9wRkGkVHlI8hZSu9ALQOn_G0iLwfHT1qTwoVLGz79Ctxa7OZyyhzToSMU5MA==	100000.00	\N	\N	2026-10-13 17:20:16.655008+05:30	\N	\N
3	Mg45	gAAAAABqzhr4Qw27MaEWNBCLC-zXqSwmR2CynCYIE7X_okj2GJpC36dDMe-TZ-dln08jwJyaC2x136HfJTASExgZEb_2kb2BDQ==	100000.00	\N	\N	2026-10-13 17:20:16.670457+05:30	\N	\N
4	Texm12	gAAAAABqzhr4SG6FJUN9pXNJMobpFNuLA1m-N9QCHYMxWGajFkkMur_OQRx6BZ-4aSXkykq6u3Ga6hIn5zatmOiScD7RHKgEsQ==	1500.00	\N	\N	2026-10-13 17:20:16.684867+05:30	\N	\N
5	Oak257	gAAAAABqzhr4ny2h595iC7bf95ilHXRNCl4x0_72iUojY6wcJgDfgRjrILvk_2GxKf7P9m2b95BGwwWKkVF1nNPDLRxLeYdOzA==	2000.00	\N	\N	2026-10-13 17:20:16.702394+05:30	\N	\N
6	Et70	gAAAAABqzhr4nY-pTblO-SrLqKb3S0Vh0_UIdp4JsLeQ-zq4JB258cACvfGjuX3EvOiCSGaHD338VmG8oxVTI_JohQEkon9pwg==	3000.00	\N	\N	2026-10-13 17:20:16.718767+05:30	\N	\N
7	Et90	gAAAAABqzhr4hp0gXm4Mlh-fUeXVzzOkyROXhMlj9y3CxVDbqG3M5Xwk8KCQ-m1s7rs5utMBZYT1zdWH9zqLxxLkwW5WxW4tTg==	2000.00	\N	\N	2026-10-13 17:20:16.734695+05:30	\N	\N
8	Et47	gAAAAABqzhr4ztFqzXtQuYf9JHPmkDC-vjSR8qM-5crNThfQDfYVpbc6vYjgxQ19QPHsZedrBvM7MsCXsxe6thTpEm50ytHEmA==	2000.00	\N	\N	2026-10-13 17:20:16.749237+05:30	\N	\N
9	tf8721	gAAAAABqzhr4jyZ4jbsMb9CctJfEr2g_kRSKHlcIn32I85DlTqDosSII_Gzb332u-YYpSXnKcrYcx4ouzOyBKO1FuBToxqZvlA==	10000.00	\N	\N	2026-10-13 17:20:16.764309+05:30	\N	\N
10	Y5115	gAAAAABqzhr4nCTar88osT-UTq4nvmVXwF3cxZrwZhigzueLOheKb8Gj611jL1MilHCLi_0x_sb22SRhTjx922PBiQp7gJKMpw==	10000.00	\N	Dallas	2026-10-13 17:20:16.778665+05:30	\N	\N
11	Pr219	gAAAAABqzhr4K7L4tBdgRpyvAyQpTW_4AWkFnoVt_CCVZA5I09hYS_oc89jSDjWwyihu0akD_vdKFC_ZHAmJJEuqKdP04XajjQ==	2500.00	\N	Dallas	2026-10-13 17:20:16.793984+05:30	\N	\N
12	Co12	gAAAAABqzhr48Sv8fcYBONNnnYE9SPe7fF5wp-tShxNVkf_wzWwJQGzXdjbKLJqsL_C9GsIJf0vF75L22jdfwNzDbdZY56XW5Q==	100000.00	\N	Dallas	2026-10-13 17:20:16.813099+05:30	\N	\N
13	Mg29	gAAAAABqzhr4FCjLk1ItQpsGA_1QThFQBh31gReCBqomneYOh70wvjY_EIB2oDkK4XzB5bDz4l8_1i85DI3SXZG6xSWv2ucyAg==	100000.00	\N	\N	2026-10-13 17:20:16.831394+05:30	\N	\N
14	Mg36	gAAAAABqzhr4iDQHqX902ntcEuthzsvMmi2B4hYOn6B-esrS-YC5jOd3LDC2SDymg8WpzKv9CPCMmbrsO4NTxaoChzSDFm92GA==	100000.00	\N	Dallas	2026-10-13 17:20:16.847718+05:30	\N	\N
15	AT46	gAAAAABqzhr4LLc0xuI2mbFF3wk0gjUtFnvEd2FuQMoxxdOSSzqzRlUkp-G-sGLp0QxgQzQmn9lEyt6vPDgZKrel6O3B6LfKAw==	300000.00	\N	Dallas	2026-10-13 17:20:16.864228+05:30	\N	\N
16	RP86	gAAAAABqzhr4bmC65Dhbn_9bDgwhB_NRStKOAX7LteEEajTQggEuNz5xPgzxLZJMUcYiOCql3dddMrFlrITFKTwERhFbfQnipw==	2000.00	\N	Dallas	2026-10-13 17:20:16.879922+05:30	\N	\N
17	Bc105	gAAAAABqzhr4yU0zPE1WqiKCjYAWWvt1qIYE-S5KzG78Gf1x9Ko1lhQsCxxqCvndNa1-lh4GYH3QVS9AbYx9GB9J3XVn7zgCoA==	25000.00	\N	Dallas	2026-10-13 17:20:16.896799+05:30	\N	\N
18	Bc115	gAAAAABqzhr4iZrDi6tR7VClArsS-maKyn3mINbjUAgg4eAI3-F9pSH9TkOJy6lInTvZOnOx5Ohn7toqnttPZt-9APQkfFA_Ww==	25000.00	\N	Dallas	2026-10-13 17:20:16.912425+05:30	\N	\N
19	Bc116	gAAAAABqzhr4dZGOTiL8rKGb9a1brnFG5FoGM-kFYm5RshrLdPlAoPijiyKgniVk0JEunIcaC5wI5xlctfGf7xxEbu1oVJdXwg==	25000.00	\N	Chicago	2026-10-13 17:20:16.929325+05:30	\N	\N
20	Bc117	gAAAAABqzhr4IXZUhZmfv_sega54uTHQp3fx_hyI2Qwe7J1mBQmVjPwqDEDeW4uMma8MMTh8p_0nCgbk_dmzmxOpUcVNNXysJw==	25000.00	\N	Dallas	2026-10-13 17:20:16.948205+05:30	\N	\N
21	Bc118	gAAAAABqzhr4hFf91Fsb1sV39gJVtQj7OCsVkL7xDoWQOjZPONp-nSjkiFlFhWtRL3AcWGzFXocebknB5MPGP6xH-CoS0TMHYg==	25000.00	\N	Dallas	2026-10-13 17:20:16.965002+05:30	\N	\N
22	Bc119	gAAAAABqzhr4G9yFBvAD8hvw_rfPOkmevQte6EEVlNCVTRnK_7iukbNzcPO-fEfn5jugy9juzacYD_NUIsTZo8c1jONwblXEoA==	25000.00	\N	Dallas	2026-10-13 17:20:16.980896+05:30	\N	\N
23	Bc120	gAAAAABqzhr4QRI2k3S5Miuheysb2PpETNQoN4CWbp7FV9NLNZxt6ZVEqAittTJw6H8kyFTcSrQhwAL5VzjQLk8mEjkwlW5uOw==	25000.00	\N	Dallas	2026-10-13 17:20:16.997893+05:30	\N	\N
24	Bc121	gAAAAABqzhr53AQkzYqecQ63FhFHaEbtpEim44wk0mihpXy57x-2qI-sTjC9atoK1XdZhrJ4Y26Sx2s41a4iEuxsyUFtDjDPuA==	25000.00	\N	Dallas	2026-10-13 17:20:17.01457+05:30	\N	\N
25	Bc122	gAAAAABqzhr53t3WpV6AWN15Lc8ynEBfRALKSAHE1ODT6KNJ98x_ScDpulAsjgncX5EF9oHkzDfEZCx6ipVD3c5qkU6ddzhDrQ==	25000.00	\N	Seattle	2026-10-13 17:20:17.030691+05:30	\N	\N
26	Bc150	gAAAAABqzhr5Oe__D5cBig_HjIM4ichkAhWa322R97t_t22ueF8T9rfdcq3BVoCn5UlvW1ONN_aDopH3-vikUQjTqsC8HuszYw==	25000.00	\N	LA	2026-10-13 17:20:17.046068+05:30	\N	\N
27	Bc151	gAAAAABqzhr59J05u0DOx-3oBSzX2dYD1v99FGDW2fVhuHxXFRe-hRRd78OmPrW2_L8Ed_Km-MQHab0RebjzMcfqDCpElSIm9g==	25000.00	\N	LA	2026-10-13 17:20:17.062562+05:30	\N	\N
28	Bc152	gAAAAABqzhr5UnL9L-_lVHiUfWWZG0BOFt0wAOoAqUKlWbt9RnGEvvDYowvsZeyni_rAH1GUIt93NixXDVr5nzWQDeWh3uVivw==	25000.00	\N	\N	2026-10-13 17:20:17.078099+05:30	\N	\N
29	Bc163	gAAAAABqzhr5nquvoMmt0rf5Ibypw7CY-e_HYQ9MBcBsjgv_jmfP_ts0GVDNiV6WE_z6IvzNEnkNkdk61_Kmt0Hp-ONzsDZ22w==	25000.00	\N	\N	2026-10-13 17:20:17.091897+05:30	\N	\N
30	Bc164	gAAAAABqzhr5DOWyNTr3BYMAZJzzWC6etGrC4BOXeb1tgJR5Jifpb1keYbVEivbtFIybH4g2bQW0aWM77AoAClxvDDuhh3K7XQ==	25000.00	\N	\N	2026-10-13 17:20:17.104956+05:30	\N	\N
31	Bc165	gAAAAABqzhr5D9XEYN_dEbpQpKEP9yureXkMZwFZRIn6GI_hmbVJe19MKww9vPiFObpD9HamftCBz26Zq7x3sJL_Vsazf86VnA==	25000.00	\N	\N	2026-10-13 17:20:17.117949+05:30	\N	\N
32	Bc166	gAAAAABqzhr5SY7f5kfKYNADNWSOHoBI0onjPCO5_ZR8EkBmRMpvpbVz5-kHpvG20vq3RrjPj7JjV1uqCfSpL72mCL8en29UzA==	25000.00	\N	\N	2026-10-13 17:20:17.130237+05:30	\N	\N
33	Bc167	gAAAAABqzhr5Jiz3znU8V1kYHXC_7kAH1Nz_wuLmGLiK-Mmgmd_oNAueXrjmAaLXjk2qXmyknpFUX7rlFPC2aUCFbPVbJY1IFw==	25000.00	\N	\N	2026-10-13 17:20:17.144974+05:30	\N	\N
34	Bc168	gAAAAABqzhr5ryUehv6MMpZ8Z8K2He7GdUeyoS7RNjHKcDIMWmHikvqXVb2gH7P_05qvVy4mT7eT24yBIuYA5hwF1wO9TOnf7A==	25000.00	\N	\N	2026-10-13 17:20:17.159256+05:30	\N	\N
35	Bc169	gAAAAABqzhr5Pu7JUGRYyO3ilpE4dp-HRRAEL2R1Hn84FP7FZivk_0Bn0dN4H6948-ZE-12C1oQTvNA0PbEOYV9lIYhq3yqMng==	25000.00	\N	\N	2026-10-13 17:20:17.171812+05:30	\N	\N
36	Bc170	gAAAAABqzhr58gcZmE-AEXA0F3dIjlM2YFQ76LvLRcljWJ43PyzRXyxTXkye0fHx6j5z4b4OpR_O5REv1DssvV-PUgVaEoMDWA==	25000.00	\N	\N	2026-10-13 17:20:17.187389+05:30	\N	\N
37	Bc171	gAAAAABqzhr5Nd7jz1iGnWMhXdGooji4sBsYCCIikJAS3JNTks0Tx2VNRGJMc7JzG-3j-hzYI9IkP2PmZz4N3QIJmO9tuYI2Aw==	25000.00	\N	\N	2026-10-13 17:20:17.2018+05:30	\N	\N
38	Bc172	gAAAAABqzhr5Mn480oo2NODCelxmRxx9szHr30SGCXnzsWZogK5pRZ1dq7UbFJPnvsLrOaldLnC0mB6cJ8CRYLEi2DqSFff-Kw==	25000.00	\N	\N	2026-10-13 17:20:17.214706+05:30	\N	\N
39	Bc173	gAAAAABqzhr5csSmBiFSxDAqT3QJrO0Zgv-De4dbecxKhGEK0WKErKiFIoZeVfbOz5L8nq1By55CkUbhbFx2STV6-wl6U2vmvg==	25000.00	\N	\N	2026-10-13 17:20:17.227514+05:30	\N	\N
40	Bc174	gAAAAABqzhr5pY6W7lr567viUSSfN5QGk4YSPWTDbwe6CWRrZP0Xt8F4vdl7QuHO1FwkYA3Psmo2b0WLo2xWEmhf-Xv58vMIXg==	25000.00	\N	\N	2026-10-13 17:20:17.238772+05:30	\N	\N
41	Bc175	gAAAAABqzhr57pM29lx-cplCxACdpOuG87sdg60gD2OaAUt08KB__I9dWzNp62dio2EOHOYidXFRxN6q636E1itvZQEqIB1tvw==	25000.00	\N	\N	2026-10-13 17:20:17.252857+05:30	\N	\N
42	Bc177	gAAAAABqzhr5ub2SQk08Nv9aOOiGjmw3lfu6FhuF_5lvw95gfibJo-scTQUg8Xo4oGbgOl5AT3HU4lF6e3Wf74IBV7dzMNb8FA==	25000.00	\N	\N	2026-10-13 17:20:17.265974+05:30	\N	\N
43	Bc178	gAAAAABqzhr5tddnygLqL1mQ13t8dm0nKnAdnVC8zxNquf9ros4XwEAk4gnvLWUt_Bk-YkunutGKKW2Jir8cxdllHTl8nZrI7A==	25000.00	\N	\N	2026-10-13 17:20:17.278836+05:30	\N	\N
44	Bc179	gAAAAABqzhr5bxZ3YacYJpxE5GJKqwhkbbjDF295x9UgFdNh_KBxB1psbJN7SZACiPaXK-yS2yZF_thFC0yO3N7YVxF3IgnrQA==	25000.00	\N	\N	2026-10-13 17:20:17.292151+05:30	\N	\N
45	Bc180	gAAAAABqzhr5k8SeQLkOZaUz2kXbE-2Al5HlKR7pqzoBBexIt4jO5ndB6sJhD6WmLUmid72H8vc-JeAvQjC4VpKJWTbAwXGRcg==	25000.00	\N	\N	2026-10-13 17:20:17.356623+05:30	\N	\N
46	Bc266	gAAAAABqzhr5q-zVaIKskTddEuRjcBRS35d-IiqLP8muye9ZGw6AwlmR-2pPfVMEB-4zBzrFAagHnkPh-urVj29nX8_FZZu5vA==	25000.00	\N	\N	2026-10-13 17:20:17.371253+05:30	\N	\N
47	Bc267	gAAAAABqzhr5flQvH1NZ85AFHkpQARnDK7ZETYVvGYtclBxpyVY1jYoovsVcle5a9la8trGIbq-Xu2rIwWcMPHlQ6RTBqei5mA==	25000.00	\N	\N	2026-10-13 17:20:17.385138+05:30	\N	\N
49	Wtz363	gAAAAABqzlnlhnR3shvQQuh1M9FZ-Podh1P5G5ORhLEkuiNyeXAa22nXE25DrwmGE2jlZZsVvRprrfDrJi4T6rk3OyaRyQ4Pjg==	500.00	1000.00	Chicago	2026-10-13 21:48:45.546454+05:30	\N	\N
50	Fsu117	gAAAAABqzlnl2kIbqxeWYuZIHEwE4stAEUp_r3-TjfXk2TBO-Mabfep5TA9OE1NAkCSiQ4xyLVqaMflauzQU3wc6ogqgMnyNdw==	25000.00	50000.00	Las Vegas	2026-10-13 21:48:45.575683+05:30	\N	\N
51	Coop02	gAAAAABqzlqHUXj-nWeGB2YKl0L6AvAOmxxxpSt1TGlpeyFplVSGimCl7eLZx3hBAzC1LDt1EIuha37bsb-yJHWMBIkBDL_MMQ==	20000.00	20000.00	Dallas	2026-10-13 21:51:27.235724+05:30	\N	\N
52	Garnone1	gAAAAABqzmE8HtZErn5Ccg6_OVtYYU543V3Rr139pGgtPlDH-QkswfmfjRWXUlDWBOwsXIcWGERWFx1rNiGIcerVdrkKOKBD8A==	5000.00	10000.00	NYC	2026-10-13 22:20:04.1437+05:30	\N	\N
53	Kevin9	gAAAAABqzmE8NMs-jTHy_vLCeAO0uJQwi77wsQOLw51njwndIxIf9IIliej-F6Xttf2QQxnqrR5brg-w-uWhrVesPM4nEmXRTw==	20000.00	20000.00	NYC	2026-10-13 22:20:04.173524+05:30	\N	\N
54	Sb975	gAAAAABqzmE8pWVKiYhyU_3KzcUZMYC5UQ1jL_wBlGEzhk9VI3kJXMpyE4o0OiiJLW_C4yge_ycGmGfuNiFtFLe8eQYYuX3s2g==	20000.00	10000.00	NYC	2026-10-13 22:20:04.190365+05:30	\N	\N
55	Whale267	gAAAAABqzmE8oIUFAnxXm597jE-3PTQo_osQiay5-_XOoLWZhU9jqHmOAKEtWshWFOOnvAFnydiwoJAlWcjsy6FBnSsfCSrYtw==	60000.00	10000.00	NYC	2026-10-13 22:20:04.205906+05:30	\N	\N
56	A7908	gAAAAABqzmE8B9nkyLQNDZr8FZ7H_nrizCG7JySyYG1YgiR5U0w1T83nf1UNf3i2AH1LIsUG4lFf2gqyQHrbjTOIHNGMTtTpfg==	5000.00	10000.00	NYC	2026-10-13 22:20:04.222752+05:30	\N	\N
57	Q6572	gAAAAABqzmE8msFL9LeeOLxpPlCl9Qn5QtMDXUMv2Y5M0uhT2BLDDp2wV9gcX2Vr87So6Bq6ygdaouoLDih9sKR18jApg-X_pQ==	2000.00	10000.00	NYC	2026-10-13 22:20:04.239774+05:30	\N	\N
58	Bax108	gAAAAABqzmE8kpqTDBcuF8V4Bi4jcaKPpEnO0Rp9o9U-bYH7GpTZF1t0U4KEamItHIZGydeYK4SbRziX63OCPyH6-AFWZPmYIg==	15000.00	10000.00	NYC	2026-10-13 22:20:04.258542+05:30	\N	\N
59	Plat14704	gAAAAABqzmJ6m6asYI9sQPcDyq_FE2bUyceNh3l20FgaCPWw-3k8EBQVbX61L1rutVZrFGpoP4y5w3valula1qGX58CLrVewBQ==	10000.00	\N	Dallas	2026-10-13 22:25:22.44062+05:30	\N	\N
60	lnk98213	gAAAAABqzmMI2xYFO3LH_kLe4G38gJDICzl0m_rbGN_99W2_fKyNa32-RAlTIn4193s-KNvSuS53AkGyFXWW3ZAh-DPJRJWQkw==	1000.00	2000.00	San Diego	2026-10-13 22:27:44.186422+05:30	\N	\N
61	Ron00x	gAAAAABqzmMIkk-cJPmq-12ztQEHpDimdTACossSYtT0UMh0sbR71XSaGG6s9xtF_kpJutgXMkVs3HcbYyHDLGtb4vsOEFP13Q==	750.00	1000.00	San Diego	2026-10-13 22:27:44.213438+05:30	\N	\N
62	ronpat321	gAAAAABqzmMIn5Ng9XV-u-7HEjWcwEMWqz6H23U2etwITHPrlWyZTrMQrQdjXYEsJxe1hait-FJcgIf5cZk4FE5bgUFIeF8P0Q==	1000.00	1500.00	San Diego	2026-10-13 22:27:44.291725+05:30	\N	\N
63	md23550	gAAAAABqzmMIR34X13xL_Na6CiNtBbABVZIp-mxUup0Tf-KwBZ8PW9Clh5ZYHrJMOZXi5AN1F4koP4_ctnYu35Xdi3P-n1yQPg==	500.00	1500.00	San Diego	2026-10-13 22:27:44.307575+05:30	\N	\N
64	RODEO2	gAAAAABqzmMIQHZKzE3aqJFgiHzhOAZYFFpT6jpBASA1jEwaRGOC_Nd1hm5_YutRpNfDhlovCxurEJ30Aw4ngys3gJproNPCVA==	500.00	1500.00	San Diego	2026-10-13 22:27:44.324646+05:30	\N	\N
65	patel714	gAAAAABqzmMIMJsmKEuME9v3KUS-xgby51vcInqLTeo7hL8qqo688dfVKHsHk5PWFQdpMUXTB8EPVrV7V7dGXydYSe-7uipyRA==	500.00	1500.00	San Diego	2026-10-13 22:27:44.339413+05:30	\N	\N
66	AMG815	gAAAAABqzmMIjM4zGl7J1ugxOYjqKb1oPkdw7ClRz2wFIGN0AaGYsv4PIgmTFYGz7Fv7HuxnmFbobgc5WFhNFVeqIKdk9zYe9g==	1000.00	1500.00	San Diego	2026-10-13 22:27:44.354967+05:30	\N	\N
67	RONPAT9457	gAAAAABqzmMIp__H98RpmOtNvOnpg0YAEifLGEQOAJtElBZkcs8rXA5KxBNGt61HaJAOWsHL4hmat-X4dvyDZJz0aTqpu_O12g==	500.00	1500.00	San Diego	2026-10-13 22:27:44.369109+05:30	\N	\N
68	Ca133	gAAAAABqzmMIV6Vt79NBn8mFpG9u_8k2bGSmSityGEwBe_hsdPrQbh1QXG9iPffyDzB1j1jB3ZOVH-g3T3DJctz0pjVepdjXsQ==	3000.00	3000.00	San Diego	2026-10-13 22:27:44.385019+05:30	\N	\N
69	Ccm166	gAAAAABqzmVn09loJzSB-ROMkQrmR5sYqtnIlHI4OZzIxwS-JZS5gvoIHq5kCp6B-gFqvREJvRhzRv43R89GqOSi_P50o5uXKA==	1000.00	1500.00	Leawood	2026-10-13 22:37:51.100548+05:30	\N	\N
70	Jsheplak11	gAAAAABqzmVnMZqPhJYV3VmiQp3Udc5qbgoduphWiBK0-Id3mUb0L18mEJl4ndBFqXI31-HT5R620MTszIxGCPR8dkOYp_v0yg==	1000.00	2000.00	Leawood	2026-10-13 22:37:51.127516+05:30	\N	\N
71	Jw515	gAAAAABqzmVngeQFJNNzu4grqVj1I_fU8AsEKqvyewL72CobdUJjpdEuybetAFJuCM2T8ezJHGUlaB8GqTk6D6ZOOtXbPUs2Bg==	2000.00	5000.00	Leawood	2026-10-13 22:37:51.147864+05:30	\N	\N
72	Jsheplak14	gAAAAABqzmVntQqYcFwbLKtFkL4ml2ZhzWKEkJguPUZxNUeXFq2zavNDV4IWoaldmfUJHPuCR3M_jluGJCHyex2ha7fWWOmLew==	1000.00	2000.00	Leawood	2026-10-13 22:37:51.172139+05:30	\N	\N
73	Yng102	gAAAAABqzmYmASdL1nUb3sHI5qciAdE8Qpea9JLQA4FwdTRPi_nwngPG-mTlzID5HybsamtIohkrPaK1PxAE2Do0eg63FJgdcg==	5000.00	\N	Dallas	2026-10-13 22:41:02.271121+05:30	\N	\N
74	book5004	gAAAAABqzmbgrTaiJ4uiuFdbf4riYnMJ9_5sviXONvOmAefWxSXx-4bAGKFJeg6cQ7-n7LqBzI7mg8XLzoLaWpaxL-ZtDcPVTg==	10000.00	\N	Dallas	2026-10-13 22:44:08.467819+05:30	\N	\N
75	Ua678	gAAAAABqzmbgXergtNj3a0Er4ny4awpAXnsfGHvNz8P7JOxeQXSPzKbCRKPMqvk_JuOp6Cjs3Scce62WCEBdsnGvwNLcRFqtpQ==	5000.00	\N	Dallas	2026-10-13 22:44:08.495192+05:30	\N	\N
76	Pw20	gAAAAABqzmc_qMCB1PfdqQDHgnVxEP-D4mCCl94H8dE-IGdpFbrZo8zuYCie-PIYOo2j39zUvHcyl7NIvDK8_DWpluEzFRGshg==	20000.00	\N	Dallas	2026-10-13 22:45:43.314579+05:30	\N	\N
77	Pw21	gAAAAABqzmc_ggrMimRFLNDAZZxlYs06sDwUasCgv8GRKFu5gIqGkE3LyYamUjbIjrkAUSlW-NqEwZgvslMGkeMn2cxlYXXrYg==	20000.00	\N	Dallas	2026-10-13 22:45:43.341354+05:30	\N	\N
78	Pw22	gAAAAABqzmc_BsIZ2S_FWWrGLNNDnY-ck-IIH3zytSI17LIzbpRujiDVsPyEqvCMsqyPNGS_ZghEf861qxmPAuSUoqmTS_dxDg==	20000.00	\N	Dallas	2026-10-13 22:45:43.358179+05:30	\N	\N
79	Pw23	gAAAAABqzmc_a7rZanTlGPeM7yKrQnXXcSHHBwW-3BOzVbDr77Reh-e-VVYGwtJJeMXYaE3x1X6E0VDUZkGqfn1rsShSj5Xi3Q==	20000.00	\N	Dallas	2026-10-13 22:45:43.373637+05:30	\N	\N
80	Pw24	gAAAAABqzmc_CfMQ8ov06fLCrAz-6J3cERHm7g7gcob6B_XU_kwaq-0zHMarExgFqV6WKcZVtSU4-JBPMSbKgmMP6s2S3UY8Iw==	20000.00	\N	Dallas	2026-10-13 22:45:43.392369+05:30	\N	\N
81	68301	gAAAAABqzyEBdTM2gOd22YKqUmPEplyKAVuvlLlS2Jq7FwmqZnq1D-D9HXJ1LbmQISrxShL-UhxJ-cfUF34Zg_r4MnAC1qG2HQ==	500.00	1000.00	Dallas	2026-10-14 11:58:17.7894+05:30	\N	\N
48	Db6211	gAAAAABqzlln2D8RgCgEJShprD2ZYT9_5lkg8wh7fj3RZCOJs5tP7xWM01gOTdpDbn88RPVPeK4VYO8NUihr9IjEPu8jo8o5zA==	30000.00	\N	Dallas	2026-10-13 21:46:39.400865+05:30	\N	Unlimited
82	b2229	gAAAAABqzySFt9YVCuYS0VvghumwyEmle74uKwFFh3wNdGo_d1tMf6WZugmH3WQ1xLxtlXli6d95QaoIHlvfFDbv2m9LmpHPhw==	50000.00	\N	Houston	2026-10-14 12:13:17.638332+05:30	\N	No max
83	Db6219	gAAAAABqzySFgTJUqq81t5OjhRin7kBd2bGRHfjjeiC6uyfmzxr7Ie4_cgn4XK0AE7MNgmWJXOlYT38RDrUwcv2SXf5VF2VQJw==	\N	\N	Houston	2026-10-14 12:13:17.673103+05:30	Infinite	No max
84	Bas613	gAAAAABqzzDA4-0t2Zrqhx5XApnfJYFUp1DpdQ8pqoRUom5fwJ8OQenqt-zE5fEu-fuoWEGGRkD2AoPmc3Loj5wGVm7W_qPO5A==	10000.00	\N	NYC	2026-10-14 13:05:28.469219+05:30	\N	\N
85	Jb710	gAAAAABqzzDAGb32oBfRBHtbV9hdyauU8-AlxCsz5oxDGkGsO6tKU_WWqFT9UODSD17GbDlMCsGTOBvYJtLmSh16LC9Z14Nglg==	2000.00	\N	LA	2026-10-14 13:05:28.490113+05:30	\N	\N
86	Blk201	gAAAAABqzzDA4TcZ6lA4plQegV0uFRCLufcggQxap9e_y0Gk1ThiGLqAsv25my5hVBH9Z-8lx2dDULhsJS-hfI6BKBTO-V0hUw==	15000.00	\N	Dallas	2026-10-14 13:05:28.512528+05:30	\N	\N
87	Xkm987	gAAAAABqzzDAxhVMpUKNut9EzMl-10-8ezObEze0XGlKywapGkL-1_hTplXA1VM7fmCEBJYx7UtfpX2pMb7gsujRvrupkHtaxw==	5000.00	\N	Dallas	2026-10-14 13:05:28.531851+05:30	\N	\N
88	Julianx2	gAAAAABqzzDAE-34vetsF4GJkPVfN2L6eQ9Byc1oIwbGX48xIjAjhEnPe8H6M9_CEgniPTvJzRTmBDSacERVPcSmabpDqRQ0Og==	700.00	\N	Dallas	2026-10-14 13:05:28.547871+05:30	\N	\N
89	Pro1018	gAAAAABqzzDASmip2MM4vM15gHmsH-DGRB4wsGnyU5sCByiQcUlwDfk_I6HWOIQ_GdGvIw7EKM0LypodvhnErtMiBo4o4Jp6IQ==	5000.00	\N	Dallas	2026-10-14 13:05:28.563811+05:30	\N	\N
90	dd0027	gAAAAABqzzDA8Oc8FDNjpxB202UHQuO8lKp7A_rUQShdBiD40NHIV0m0Hbp5TJGg2cykepbRYKckV-cpZsAT_T5LcZNSAMHdEg==	15000.00	\N	Boulder	2026-10-14 13:05:28.581116+05:30	\N	\N
91	Apo109	gAAAAABqzzMbT1ZrCpP8MKRj4RcTHFpBfZjDuKpfSaQ1TTRop-PQKQBVEv6gTbI1Gg6NSNWNB93Hh5S0fC_oyi4QDi5Cd3UOMw==	500.00	\N	North Carlina	2026-10-14 13:15:31.281299+05:30	\N	\N
92	P7	gAAAAABqzzMbylnTePqRW1VcJYP8bKyK2tpYNvTit1WjaQItaCbY9B6gSc7hkM6ok3pZfm1oshsjrEBpx0CHoC0oJmCimy4Aow==	3000.00	2000.00	North Carlina	2026-10-14 13:15:31.309537+05:30	\N	\N
93	Pr2729925	gAAAAABqz0g6UGe_HbieDUBRUtqmPAb4U9Vz0WJk-3dOWdUBPvMDpT6M7HaieE3An2naPMEjophNjQeaRwt38zx_zVfSkm5Gmw==	10000.00	10000.00	LA	2026-10-14 14:45:38.751637+05:30	\N	\N
94	30300	gAAAAABqz0g6H0UNK0KnDl3iFxz3p01jwZ-6x-KMejjiu5tZxwTAd9cPejLHGfCma7u-KeZRzoziKlx8RqFcZzUTbBdxg3C83Q==	20000.00	20000.00	LA	2026-10-14 14:45:38.791863+05:30	\N	\N
95	30301	gAAAAABqz0g6Hxm9h_jITiEZAaZpJJDKGs7xGCGFeXufiIkzYpwPGORWGb90060i4nLg2hPa4GfKLZV5pHhVXI4fzu1UmPuBSw==	20000.00	20000.00	LA	2026-10-14 14:45:38.831563+05:30	\N	\N
96	30302	gAAAAABqz0g6sQJMCTUAxg35ayNQ_0eBBloewuErasTAwI5ieYc3pSeupWfzlTgRca87K2zlGP56yd4muF4-_obG1RcUiTTkiw==	20000.00	20000.00	LA	2026-10-14 14:45:38.859742+05:30	\N	\N
97	Bg904	gAAAAABqz0g6B7pd0HEkfCzTEy3QuUl7BUNFL2vyUs2aAA1RNNpPEDLSirymCcMgc3IDPNRot4WagdmVboyFFBs7J4GUzLIdjA==	30000.00	10000.00	LA	2026-10-14 14:45:38.885074+05:30	\N	\N
98	M8002	gAAAAABqz0g6t08uxWgitobT61kgy9cn7FXSntUkI7E7oJelXEFBHwqbSjJO09DCeR9WkCXA1fpsUC8RxngwgD99VqAaZ_9QcA==	10000.00	8000.00	LA	2026-10-14 14:45:38.91288+05:30	\N	\N
103	Gem001	gAAAAABqz0g7cNImdOr-koIorjZ8OStvTtHiajb25O-sRrJ9a3buxuLr6EO9rITjOPRYwctB5LcsmNSweT5ki7F8M9IKOFEjCQ==	20000.00	20000.00	LA	2026-10-14 14:45:39.028079+05:30	\N	\N
108	Top101	gAAAAABqz0g7iEOvyT7TFyPFggsgKqIvyvw5BP4Ao4j8Ch7Oltaf5Fw9nKn4S9yr0RZEanc9_Lp24tb6SYY09hcK0d-4e5w1xg==	20000.00	20000.00	LA	2026-10-14 14:45:39.12127+05:30	\N	\N
113	Agt900	gAAAAABqz0g7oIXpJQwsAemgpF6eERkxyyp5VlVGKvSOCc_P2PAhdCv81nhuqtWMgraaRqeJXYk13LUbUIA5WruhWf_Mc7MzXA==	25000.00	40000.00	LA	2026-10-14 14:45:39.27751+05:30	\N	\N
118	Tt823	gAAAAABqz0g7dNJZZztPDX-xX_fnEt0fjAyxWCkcB17QTm9P2mNfo8NS-57moKXDcBZqyIVpJ3u8YM7iEl80Qc5TD7h3FZ2Qfw==	5000.00	10000.00	LA	2026-10-14 14:45:39.41441+05:30	\N	\N
123	Dt753	gAAAAABqz0g7bTgRqalBCSV_DaAT3OvQcMRdkjjwFCFyHHpAiIxt9dp5Yyl-LUPwQnqSoMk66VeshrcegoPeZtncLsbCD_rDAw==	10000.00	10000.00	LA	2026-10-14 14:45:39.528004+05:30	\N	\N
128	Dt229	gAAAAABqz0g7pjghpoLuajcvSNZL1GXovP-aD0m3q7WbzFRlRF2vozrmLPbCAL9Vmy9qeYanfwF6tNOM8r2-ubaVdfNco8ZjWA==	10000.00	10000.00	LA	2026-10-14 14:45:39.652562+05:30	\N	\N
133	Bh014	gAAAAABqz0g7XzCuo3VmYIs6BloGR5Xxl7U4qmM5A_Vfo3mm2eBHRFiOFwEYVm3ADcuPa0PGwp4qfL267rSdBiTbgnYR1ezoOg==	30000.00	10000.00	LA	2026-10-14 14:45:39.789429+05:30	\N	\N
138	Le022	gAAAAABqz0g7MxbLdZbnPTuLLr-AXVfac7s-P_akuGQoJBrQ_77ECRBxT3Qcvrfs3ri2FthQvvfXu-whXPEB61UoeMoVP1-RiQ==	4000.00	10000.00	LA	2026-10-14 14:45:39.922278+05:30	\N	\N
143	tdd60	gAAAAABqz0g81JZO_sRo6ynViVcbyphq_6Zd7KkoASfVgzalz0_0EQzFqvc7eb9DnZURtld7uK3YyV_0BjizQ0R5vMUnmXeeZA==	20000.00	10000.00	LA	2026-10-14 14:45:40.043181+05:30	\N	\N
148	Ac802	gAAAAABqz0g89gClHjxuGYLvV5SJREEOh5ZNMdhinJYqgY6fh70YnTLMf-wxk4hkucCCTbA2gKVA_w_17LU6QIZeQrLRnwfjiA==	10000.00	10000.00	LA	2026-10-14 14:45:40.173632+05:30	\N	\N
153	Ftt27	gAAAAABqz0g8LfkErfdlcBJAgELLMENb4qw9_-mbJuhXJS-l5abfK9UhJpMnBWiZ0NtrtBdi7zhVy4-1cFgJsp90wyLlbAzJlQ==	10000.00	10000.00	LA	2026-10-14 14:45:40.28396+05:30	\N	\N
158	Pn479	gAAAAABqz0g8HpWBtRWV-AYVyjpm7ekbJ_Gz8dKcssmGq-WBAQ4MphbhcF4sacYM5OYDCJkcQRDG5eI6izNKLCg2Ai-axO649g==	10000.00	10000.00	LA	2026-10-14 14:45:40.396142+05:30	\N	\N
163	Tnt23	gAAAAABqz0g8wKbH2WQ4O4RUB80mdVMY9S9gQNMuzZN6cQlH9bxTCw7yL7Ie7Ibx5zBGA2S2ewqRWbB3ERX4K2x30IDrUSC7hw==	10000.00	10000.00	LA	2026-10-14 14:45:40.48727+05:30	\N	\N
168	Jrsdb1829	gAAAAABqz0g8p34x4ZpgpEImIzt9gHgmdwfh2rmH8D34GBGS3hk-7QCqP_eGVL_UoF-hoIsYBMt8_6A7Qiv9DzStJ8sPegVLDQ==	2000.00	5000.00	LA	2026-10-14 14:45:40.575597+05:30	\N	\N
99	Mv6647	gAAAAABqz0g6nxQfPBxC9v7_KTHv_LqQPAXzVviNe19mdlCyP6E90sVKVCsmTFFmQaws0EeoPKF3es-om0Vbc3JWkd0pyfCFmA==	20000.00	20000.00	LA	2026-10-14 14:45:38.93504+05:30	\N	\N
104	Ds100	gAAAAABqz0g7gDOtXXG7U0l3z3InnHtoPWdORZj_NvbgWpPTVGwqF8Y1s_dKx3eMDURzDQWokJY3kfm3zhksnDgwLnjkspaohg==	20000.00	50000.00	LA	2026-10-14 14:45:39.048068+05:30	\N	\N
109	Top102	gAAAAABqz0g78g-u9aSt-G3a_xtHeIdD6hIhuKeopC3AO9Tim0vldE8kdI1yFaos-1RXWxGSTXrUIveiyVlEy4ppGTYLs3xvSw==	20000.00	20000.00	LA	2026-10-14 14:45:39.151668+05:30	\N	\N
114	Jz515	gAAAAABqz0g7Qlxr3iJIYgq1lgo33lBNtoD2FdhDRc_TayvEe9ATYRSHdYDEw9437HZaM29idDfNvgBypenx5zFZ1VKsFs9Chg==	20000.00	30000.00	LA	2026-10-14 14:45:39.301164+05:30	\N	\N
119	Tt801	gAAAAABqz0g7ewv8tjpKnNAhpYUtJWKxstdgkbrkYE2FUsmX6pUmEI3iwzAsGfQ9Qsb1Nn5_AsBCXoeYJ4_X1yT4o4R5Pn0cAQ==	10000.00	10000.00	LA	2026-10-14 14:45:39.434715+05:30	\N	\N
124	Kn928	gAAAAABqz0g7ykLXGGmilqIKMJqQfFJZ15wMFHSU194TPpcpa9FLEVRK1e0TcJxIAjsbjzU3su-5iwNq5XIX01ZIegI1gOLFdw==	10000.00	10000.00	LA	2026-10-14 14:45:39.546215+05:30	\N	\N
129	Dt001	gAAAAABqz0g7r3llAtk5KvVZK3J1MmShW5nIUJlg4iC5qPjshML0aKBh-pHI2T0ypNvt-Wt5s-NDDgG6rXhqAnwCXs4LurdQRw==	10000.00	10000.00	LA	2026-10-14 14:45:39.679475+05:30	\N	\N
134	Todd105	gAAAAABqz0g7d4N8GakcujVOYWvXU6Ucv0foEMy5gXFS6dwwwsNnHMbJZmtAEyvM-KaquYOcx5a0LMcBvZYnWmLW_QLWkFscsQ==	4000.00	10000.00	LA	2026-10-14 14:45:39.812845+05:30	\N	\N
139	G0037	gAAAAABqz0g7s4edB1UiNaiVa1nNVYuv0zvfu90ZBV3h0YQWdxtB7NBt9MrXPc1tQUdsBYHIX_-XQpZktCZICGB1wVHUzkTqIg==	5000.00	10000.00	LA	2026-10-14 14:45:39.941488+05:30	\N	\N
144	bj1042	gAAAAABqz0g8NXIng2CTGxiz8z3Re4m9-ZHahjghU2rT4cS7xf0MpB3IcgvPUS78oJFBGcyTXSW0pzcJManA14298TFEzCXWMA==	20000.00	20000.00	LA	2026-10-14 14:45:40.074805+05:30	\N	\N
149	Ac1106	gAAAAABqz0g8KSgsvWAqm96t7E5DlWOgHCNk4FTyP57sEI55YgXlzYnQfxEbtMEPHqv5OxqrHUVUqjwKTC9BAPla3KExyk6Vzg==	20000.00	20000.00	LA	2026-10-14 14:45:40.195492+05:30	\N	\N
154	Ftt36	gAAAAABqz0g8QsVl1hkn2cib0avSTHIAq4cFAR-p6AOcb89rIjaPUnKQHbSfMbfWXLsIvSMaXRe9JrcUAkQe2rG4ssWQQqWsxQ==	10000.00	10000.00	LA	2026-10-14 14:45:40.308894+05:30	\N	\N
159	Pn5009	gAAAAABqz0g8PzBAT95qIzdtl54mSL_DKb5BSH8zfA3a669O9f8s2MuI7xOwHUD9N2hQYiK6_htjHYSbiKgiFccj_5Emd8Kq7g==	10000.00	10000.00	LA	2026-10-14 14:45:40.417697+05:30	\N	\N
164	Pn446	gAAAAABqz0g8nEtJtMHanXfmIba4u1RqdMHlZe9QV-xCCwgZh0lSegJqyF_G6WMGBx3PVfWLKFKwQQORAshpmtS63_zp4w6xiQ==	10000.00	10000.00	LA	2026-10-14 14:45:40.504764+05:30	\N	\N
169	Jrsdb1830	gAAAAABqz0g8egJ2HONafvyJ_Afa0tGcHuz71BhJ1gqjqtIi0dYeS8m0okrDrjBulHxbPAfBqx00ttM3pIdWNXFaNVWC1gWkVg==	2000.00	5000.00	LA	2026-10-14 14:45:40.592982+05:30	\N	\N
100	Zz603	gAAAAABqz0g6500fHJArlxEGBD3ZmZ44y6ssXIdgaJZu4Guw_6A3QnRMhY2p5uwWgx2PfK5cfhRhtOSfv0H-wCN3kQI85upPwg==	30000.00	50000.00	LA	2026-10-14 14:45:38.963221+05:30	\N	\N
105	Ds101	gAAAAABqz0g7JlErGh88Ujz1eQ9JK2Zr5AkaYxqBczk6oBbvn-AqSKEHDdorM-5Z3xcAcasFJ3QpsAjSFmi2roBtRutuVvQHxw==	20000.00	50000.00	LA	2026-10-14 14:45:39.070424+05:30	\N	\N
110	Hbo208	gAAAAABqz0g7v9grybo9bagh14u392rmmkQj2dCL0Uuy6HFIatMfesSnVYziGthi1rvELgKBBTFkOCZ_v3y3lfZ3ugTS00FSfQ==	20000.00	20000.00	LA	2026-10-14 14:45:39.186663+05:30	\N	\N
115	Qt511	gAAAAABqz0g7FknsMtu8fF7_40cMQYgU8CRi5S1QXFBhRiDuK8Sj4Gxm1XwzguCDRJSNrZqbsLN1pSH8rud2SdpnbcVjkp29aQ==	20000.00	30000.00	LA	2026-10-14 14:45:39.330079+05:30	\N	\N
120	901	gAAAAABqz0g7FMGJU5HqMCvlyZAaTgjaWvR6q2MmYs13AdMzqEhPupGByt834cqiZCzPfeOajzJ9E-1WxEuH0ZaxcUmolqyyQQ==	20000.00	20000.00	LA	2026-10-14 14:45:39.452675+05:30	\N	\N
125	Sf133	gAAAAABqz0g7bY904HTXhgePEKzwky0D2BSCf_273M7yPp-z7EcRiUj0CSue8rRzPVm4T7f6jZc7XCFR9q1hMDh8_6ueW4OLuQ==	30000.00	30000.00	LA	2026-10-14 14:45:39.571852+05:30	\N	\N
130	Tu282	gAAAAABqz0g7RoA2_M5aMANT6UWFad8rdParVkx_nVumDQIdpbsFkr_bt9KFpsTmh_5L0yi3PFG-IBwE_fYZENYJDR9xobs1mg==	10000.00	10000.00	LA	2026-10-14 14:45:39.703134+05:30	\N	\N
135	Todd109	gAAAAABqz0g7xw25QerYlJHE6CUklTqkYgql_hs7vEstmC9cyBPFmN6RsFglucm70YrObv7W5x5nni5ngNKndX8n3J-Me8AQ8Q==	4000.00	10000.00	LA	2026-10-14 14:45:39.835414+05:30	\N	\N
140	g0032	gAAAAABqz0g7vo4Q04_mMzdw2c4dafkxfdtpViAdczhRSzrqe0Yk2sNkFHVDnhGEaZp7qE1FDXLgusp0VL-DuDvS1ZFbLpNnLg==	10000.00	10000.00	LA	2026-10-14 14:45:39.968252+05:30	\N	\N
145	T124	gAAAAABqz0g8nPCTaWe6PHjeevGjeGtHvrXkIjRBwL2P9dVfVE6OSYw4pzoY8rKO2tVuNlRCB5Ci30x600WtUwdF7sPEGj61JA==	10000.00	10000.00	LA	2026-10-14 14:45:40.098692+05:30	\N	\N
150	Akg102	gAAAAABqz0g8Wqp3TbCwlLM0WVm30CWyQNBEZoAOTvOAQFYr-y_ndBanlkyM8HsV-GIEPfOfxJOLqyE6lAhRNxIPG_4_sSbvIw==	2000.00	20000.00	LA	2026-10-14 14:45:40.223829+05:30	\N	\N
155	Ftt35	gAAAAABqz0g8HIpBpzfKSp3_7l6aE3griZNUZNncKW2ke-E6qsRsepgXb028JjkWFJqFUIUPHZfYKauNspS1vmSte3suWG7Hwg==	10000.00	10000.00	LA	2026-10-14 14:45:40.336228+05:30	\N	\N
160	Mu302	gAAAAABqz0g89ejRUfvQg3NOOOkmaauvfkMhgeWZ0stI-LbXtQKnOGhDG00Bx8R8BzrW_JQACPYM6kjjWbbQ-3_fbr75RpTymw==	20000.00	20000.00	LA	2026-10-14 14:45:40.433139+05:30	\N	\N
165	Pn5004	gAAAAABqz0g88_4WyQ7WCW6g39g-2P7r5nyrqY12TTio1-p9dRSekdTVjVjnlLq6gSfC02FIqSCg0aV2vDXiILIzyJuddpwTgA==	10000.00	10000.00	LA	2026-10-14 14:45:40.522215+05:30	\N	\N
170	Jrsdb1831	gAAAAABqz0g8I84pBOZmYIou8A1bh233tQkvCyZkZgPGrV9lAYSNYbUTZWpOlON-wnAoLD20tmQHc2GnxzBxxgNuCXHKfADKBw==	2000.00	5000.00	LA	2026-10-14 14:45:40.612111+05:30	\N	\N
101	Sa503	gAAAAABqz0g60lEc6xOgpvd-PIzj4EEiON0R5150y5aDVT2laVRxqlHq9RqJEGJXSVojcaV42NBW5Erqs7DFkKZ3W-Ub73p30Q==	30000.00	50000.00	LA	2026-10-14 14:45:38.98392+05:30	\N	\N
106	Ds102	gAAAAABqz0g7bUux7UXlOxSgpV4V_7umChLMq7eaPM8uvTUOrjK4Bj0SCD-uAykdtlaASQrG3kE5jieOWrMNPVD2DFqh8u_SVw==	20000.00	50000.00	LA	2026-10-14 14:45:39.087258+05:30	\N	\N
111	Ny5051	gAAAAABqz0g7OFqJxzu4rpjfbDYyki10-6dyjECCtpPg2ba6jvpPAA1PZBmYHLnLwVGPMW87cMyVhUGVwzYK1mS9peiUpWgosA==	5000.00	10000.00	LA	2026-10-14 14:45:39.218164+05:30	\N	\N
116	Tt822	gAAAAABqz0g72foTejyq2_AGUNcnDRZOLvUQRHKWsEpelN16qW8EU4PdI0cN5cQ3f5Pl2RDOQv427E85cz3W-W8B2PLZgrDmQA==	10000.00	10000.00	LA	2026-10-14 14:45:39.368195+05:30	\N	\N
121	Khn126	gAAAAABqz0g76kqdvN9jPGt3MTLckHkoMVrGhM7ETXJIbYx-6_NErXWvh6gQzewqd8RIU1JXrezfPexP0JYil78kS2_DwpD1ew==	20000.00	20000.00	LA	2026-10-14 14:45:39.475102+05:30	\N	\N
126	Gdt17	gAAAAABqz0g7I7wtN4tv1bo_cvXQyqqHdLjNeLAv5BiYpYV0W0Jhu0w_JSOYjlSAo6Dbmnvcopxw4XduUluIoAiOCBcRwR10YA==	10000.00	10000.00	LA	2026-10-14 14:45:39.596517+05:30	\N	\N
131	TL3001	gAAAAABqz0g7WnILSiaEH-cg7nKeXUpYtHhFjxWhVo9p1vVDztdSTi5q3xbdMNt9kmIOjJA5UH39ESU01TQLmmD6zbp5LdV82g==	10000.00	20000.00	LA	2026-10-14 14:45:39.734141+05:30	\N	\N
136	Tdd11	gAAAAABqz0g7Vj69lWwLar0SyzQnmSDpC_hKazV4R0Y54rE4Yt3nT2Zv_nuSVB0eycf9jjAMQ3oXxfup1uG2SurveG4PnlhSyw==	5000.00	10000.00	LA	2026-10-14 14:45:39.871244+05:30	\N	\N
141	Boc113	gAAAAABqz0g73dGPZn5hX5th9hbiVZjlen8vTpGyV6GPKZ1lE9iAMFsFWYHIbPxi3AB07ZxvrEpuErQiz5b4JZbZChHmlZCTJg==	20000.00	10000.00	LA	2026-10-14 14:45:39.987819+05:30	\N	\N
146	Ren409	gAAAAABqz0g8MDMh7uoA3rRNmIxClB5UqlgQPbfB-vIidqwzJW774yYP_uvFaga9N-nLFX37Ibcd35R2l03xhGPWZ7LNG6yb4A==	10000.00	10000.00	LA	2026-10-14 14:45:40.125665+05:30	\N	\N
151	Ren302	gAAAAABqz0g8SNVWLF-djAifDS1kPd9MDif6XK9VXuVZ6oo1uw9JHacCoTU017gO95KDCzV-F3uM4-e28fJ01mAo3Bx8-a2Gsw==	10000.00	10000.00	LA	2026-10-14 14:45:40.242297+05:30	\N	\N
156	Xq376	gAAAAABqz0g8Xea5vs4DslfRv1SZ4RvWzGkgzT2Yv_pkSZK-1ZgCK2rXE0E8DjMl21Pdk16txeyKDQMkKcpXC7M_Y5XFPQ5swA==	30000.00	20000.00	LA	2026-10-14 14:45:40.354747+05:30	\N	\N
161	Fr23	gAAAAABqz0g8Ah9jaif7Fh1plxa3q2f4aut7m0dar1ftgL29wZik-iVFFlaGlCLj-9nQLf1kVSs3RWcIFkpWbTAX1-1rfo0xzg==	10000.00	10000.00	LA	2026-10-14 14:45:40.455912+05:30	\N	\N
166	Sg233	gAAAAABqz0g8k8KZvmfVC9eNKtGqC0NbjMsrJ_BSTdj96zZnsm4YVUyORyJwYA25XrtaiOYhzCDcH6IoHL0mz-niZxEebjSyIg==	10000.00	10000.00	LA	2026-10-14 14:45:40.537606+05:30	\N	\N
171	Tn717	gAAAAABqz0g8bgJP2thUyRMyAfyoJnsvgm6C9i_mGIgVLsTnSLVoWRehPt7JpUWhET2CBRMDt1_kM3Ud_j3PQj7NKMsiFeQg9A==	10000.00	10000.00	LA	2026-10-14 14:45:40.628808+05:30	\N	\N
102	Hco111	gAAAAABqz0g7vGeznpuYSjhcygM7tA0lQJuZme7kOtvNoCJaAf8SasPXLdzpy6vj1XA8mG_N5GW7uOeePYOG6ShcwqKT2cZ6ew==	20000.00	20000.00	LA	2026-10-14 14:45:39.004409+05:30	\N	\N
107	p73008	gAAAAABqz0g7XWFHfq7yXGu4NMMOB1j65WCLZtawTr8Jltw95l7-nj0pZFu1QURw6j3kQsnHvmDcxn2aPjvB7Ke2Z67JhPKbFQ==	20000.00	30000.00	LA	2026-10-14 14:45:39.103962+05:30	\N	\N
112	Agt711	gAAAAABqz0g7Ks5LhECLntxJNnd0jnfbmMx4PQRf3gcM2L47Et7IGHzm3Do4N01OKaeUL6W5UKW61V8DH4MsAHnyvIxFtzvh6w==	20000.00	20000.00	LA	2026-10-14 14:45:39.247446+05:30	\N	\N
117	Tt830	gAAAAABqz0g7aSXQs4IbwsLhyxwnstz-fPJblyMzD2HlMhnnmS7MMLmAEPkBweWR-XOq6WMxhzbEBDyRgtz4lreaPDWcv-BK6g==	5000.00	10000.00	LA	2026-10-14 14:45:39.388118+05:30	\N	\N
122	Kn929	gAAAAABqz0g7uNCHalre5M9vi5s9q6SLKVtFIsL9D6t-0jq_GYxUdN6XO7eWCo3nVh9hjWsw1NnQLHCt-VFD0ITFEMggTdaOMA==	10000.00	10000.00	LA	2026-10-14 14:45:39.500102+05:30	\N	\N
127	Dt228	gAAAAABqz0g7yrVfnfzYUJSYaz6CgH5NctVzSTIgiAYQsHJSUkw5n4A7NMZr44s4YTjRRT6x7WhFPxsEEm9QvLzJT94DkHQoNg==	10000.00	10000.00	LA	2026-10-14 14:45:39.630145+05:30	\N	\N
132	Bh004	gAAAAABqz0g7gILOe1SYIRwbKHbYjZbzmGgeYjmXKq1KWQqP7ye6xpqU6kr_j_mtYW5S9LxEsyVSohinhwa2nmljPl5auCwWKg==	30000.00	10000.00	LA	2026-10-14 14:45:39.760757+05:30	\N	\N
137	Tdd12	gAAAAABqz0g7glQZUuU75mbC2MO_DAmMGGW5fwB7uQWGpz8z5kbmlFzFHgrtwm8un9m87lyBMhk7HKufrt5XQRQ11tX2ImTcCA==	5000.00	10000.00	LA	2026-10-14 14:45:39.897408+05:30	\N	\N
142	tdd67	gAAAAABqz0g8Cpthml4WQXu6MSSarCj39roRGBTSpT9G1J0NaDM_QAWv7gsYTVVrL43-UcT8KY_ZYwM-mRAVdXdwdgqHsOb9Nw==	20000.00	10000.00	LA	2026-10-14 14:45:40.016861+05:30	\N	\N
147	Ren408	gAAAAABqz0g8PBbDnWg42Hk5E8ZxaNKYOTLvK-tymoN-bDY8s9a7If_TK8V2lLVfERjOJEoX9IAwHrSs5n3_X-qAImQTfonAcA==	10000.00	10000.00	LA	2026-10-14 14:45:40.147374+05:30	\N	\N
152	E2005	gAAAAABqz0g8PlgbLR3kAQo_swG08e2I7yEJQKRaVnNo-l3mWi0P9m-AmUQN_9DMIo4mc45ELHuhG23CV9V4onYBjQ435ieqIg==	10000.00	10000.00	LA	2026-10-14 14:45:40.262436+05:30	\N	\N
157	Ren402	gAAAAABqz0g8wPKWuvKlh3HOUhz4RYpy0lRJOXtr5VheiNvQotamyJetGc0nyltCMi1s8wdyzOHjQ3A-f02NOpW6u4VIp0_2WA==	10000.00	10000.00	LA	2026-10-14 14:45:40.374156+05:30	\N	\N
162	Ot7013	gAAAAABqz0g8lb3VFKwEN2haojJ-XFMAFKeUmzIfvUPsUMK2MVARA93SRNVVBW_oEfNGkX-nkff0HzRtmOvKl3lXI4rcb5mljQ==	10000.00	10000.00	LA	2026-10-14 14:45:40.471607+05:30	\N	\N
167	Jrsdb1828	gAAAAABqz0g8RMetPRMUSKvzQRA9RnhfWHy5PkaFw7vKlzIDBji72xwnMrd-p18-N34FIv6394zsV6dYKXEzDbLHvEWycVlBkQ==	2000.00	5000.00	LA	2026-10-14 14:45:40.556327+05:30	\N	\N
172	Adamc4488	gAAAAABqz1G_oJprscu8miAX0PqSBQBqCBZLgM5EyQtuQ7bUrgAnoKvgDIu35-1qYYwXQDY-shrqItIEDf0PIDnsp9ZU76zwjA==	\N	100000.00	\N	2026-10-14 15:26:15.238839+05:30	\N	\N
173	Affm4488	gAAAAABqz1G_L260NLUxN7DAxbSSYXyaUqFRJ6UkBHnocfyYBIekgiUXHcOwtKr8kmVqCfD1XfbYMiTb6QKuDqhKGNEXagvzFw==	\N	100000.00	\N	2026-10-14 15:26:15.282246+05:30	\N	\N
174	Brea4488	gAAAAABqz1G_6F2p8yqXx6xbDy1-5V2A9IPhmzFtIKWE6OXhFDYsdmbFUG-m5F-wi9LL-slplOx8cTnqfpN6ndgNT89897PTnQ==	\N	100000.00	\N	2026-10-14 15:26:15.298659+05:30	\N	\N
175	Kb386	gAAAAABqz1G_dwUS76kWr69yYWWUyabuZ38Bqz8I1RAGmg2vKEbcIZHtw6rUnnubNxOvVO3vUq-VNRhVlg6dc_AB92h5zQM7oA==	\N	5000.00	\N	2026-10-14 15:26:15.313437+05:30	\N	\N
176	LNK566046	gAAAAABqz1G_tS4Y4Y7qQq2wvYNkCiBpss5AhvOSXP7UHFZal1MaZqcldd3aN8eqKNFwtooDDl_G199rZm3RA4yI8XcTLy1Jiw==	\N	1500.00	\N	2026-10-14 15:26:15.331102+05:30	\N	\N
177	Alecshurd	gAAAAABqz1G_EGT8mAPnMXsSClToNGem41_XUv8fcp54bf1G5LMRjwRRY52PGgRn2ud-RjFpAA4Yl_dfeMv2kRpafCn4ugfyxQ==	\N	1500.00	\N	2026-10-14 15:26:15.346805+05:30	\N	\N
178	Ccb564	gAAAAABqz1G_24VdVqoz2hC-NvYHK53Ft9u0FqSi0XXIxkAIws6ygAmDRYIBw0qp1LuikHwLZp5gAdeRfIERwq-ZhbQIU13y4w==	\N	2000.00	\N	2026-10-14 15:26:15.362772+05:30	\N	\N
179	Sk307	gAAAAABqz1G_5v0AAvjcBEPzc25g0aW8Ns3eh5efmSRx9vBKqkL3XKp0sY3cubrVMpmdlqnJYV6HnwHQPpgmOodWzB7kdblhcg==	40000.00	15000.00	Montreal	2026-10-14 15:26:15.380623+05:30	\N	\N
180	Snir4488	gAAAAABqz1G_borg_StTw_FDukGdYkOpC8o7uzXinNSp1pSLpZs6YrGbWn0rPkev2NPjqCCuicIlynkUCEQJwfap-yoTfYLvvA==	200000.00	\N	LA	2026-10-14 15:26:15.398128+05:30	\N	\N
181	Wc523	gAAAAABqz1G_Uv0BU79C67e13ykxg9hfuvsBdlQatoqnDdisbr0to_yEZn8viEa9v6qmJYMgaCJuKulA7iNznyjMMD58aiakKw==	10000.00	\N	LA	2026-10-14 15:26:15.412466+05:30	\N	Infinite
182	Mma602	gAAAAABqz1G_CWt4kCHk1x5ZTOcKG4wn76Wkcn-_Dt10xlexwWfVLLHw0ziVkCnGH3hvvTMEtkc1815VSaPMwOYitnUdaG5Q0g==	10000.00	\N	LA	2026-10-14 15:26:15.427352+05:30	\N	Infinite
183	Heo209	gAAAAABqz1G_Jb5I3qnFEWOrHVqGbhx8qm-G-q17xoOeykG0r9_1rjF2uTDPe_PxNXvGynjX1wKiuf1MqZTGmmF5Z9ZHgDisPA==	20000.00	\N	LA	2026-10-14 15:26:15.441801+05:30	\N	Infinite
184	heq104	gAAAAABqz1G_O_AG4zK7ry-lIeelnlMpoNaT2cahqcOcbJeFPFjRgagjzscDMyV-U8hP64s-PNehP3f9TY8624IxdqOyAglHmQ==	10000.00	\N	LA	2026-10-14 15:26:15.457779+05:30	\N	Infinite
185	Al101	gAAAAABqz1G_CzL1n4t2n2p6t_0HzzUeGxjpDwBboolcHvuevA56ak-gzR4gaukcXJ0EmlOrQKwWj2YzKJLVubcnWcNDWqWMYA==	20000.00	\N	LA	2026-10-14 15:26:15.471454+05:30	\N	Infinite
186	Pn485	gAAAAABqz1G_4JoWR9ZmzbNH3pEYmWhKA4OVLmQyDSbC9BaXQeAtXfWolJVLpvkiICEh3FSuYFz2na0rj1lC16f6rGIEs78tKg==	10000.00	\N	LA	2026-10-14 15:26:15.48782+05:30	\N	Infinite
187	Prt115	gAAAAABqz1kfDnEwQ5gKjUDbIBzHIT0-im7Dtcb7vyR2zBht7AD0QOBwm4FxhqtuSQF6Ue7kZL7jXizzwk1cZv3uFg1Dx17yQQ==	\N	\N	Dallas	2026-10-14 15:57:43.147932+05:30	\N	Infinite
188	B3361	gAAAAABqz1kfvkcz7uaiPJnbKOzym91m5gBw9s9d71sGwEJcqmDgenGy61CfI6lPa4iPzDNVZDTWUr3M55g0AjGULiU6K-aHHA==	\N	\N	Dallas	2026-10-14 15:57:43.17987+05:30	\N	Infinite
189	B3357	gAAAAABqz1kf18K32PmvH5DPpr8Ed3OPgfOHy_f0emGC7re_Xvcjlp-DSTvLefcnz88McKTJt3_x2RdW-ebER9yuy2zPP5G3Ow==	\N	\N	Dallas	2026-10-14 15:57:43.209565+05:30	\N	Infinite
190	C2026	gAAAAABqz1kfVsB_68H_f5bY0EclXm3qfJnTkBeR3dcVTYgPLOQVT6GwrHZXRDKgX9RobzHRSJmoCug9m9-DNmu_p--LmC5F1Q==	5000.00	4000.00	Austin	2026-10-14 15:57:43.28465+05:30	\N	\N
191	Vs19105	gAAAAABqz1kfUbZM6A014Fv9aCNkYakC6U0H1wz9UayNq3DNFKdxtn9IMx--sTB5zd4D9C_OB8DkyiBKAQKgWMIfTPCyvuwsCg==	500.00	1000.00	Austin	2026-10-14 15:57:43.313281+05:30	\N	\N
192	Za037	gAAAAABqz1kf3Lo7KXbYQNgFKWd7aB8C-Ijws8-ilKii8lsJhLTr4EWRPWBQNUoDS_jCZueehRtVUihdcO-C0bkwa1Nlggz1jQ==	1000.00	2000.00	Austin	2026-10-14 15:57:43.337577+05:30	\N	\N
193	Hom198	gAAAAABqz1kfyT0Oj9Uw6becw7e8261HK2e_UmCk1jrYpCc3uiieenKo5rbRiQq-fA4_j2AFw7X43n8zlwE6-kqDnqC0fE0K9A==	750000.00	250000.00	LA	2026-10-14 15:57:43.359671+05:30	\N	\N
194	Arr5	gAAAAABqz1kfNZsJKxSfQ6mmjpYHNo7Hq2xgmi3gUGF6gxWgwFavfZGg1TETibzeUQXJPor-8Wj3k0U_gtAU16d7x8zvPKWzFg==	2000.00	1000.00	SF	2026-10-14 15:57:43.382213+05:30	\N	\N
195	Mm500	gAAAAABqz1kfbiB4iJsBLFODiFacb7LVh6M3ai7jjc7x7gKlTJY2KSLkgh4oS6SWCV2aYtK_myr7VCa-oY-3xjywYeI3YB7iIg==	2000.00	1000.00	SF	2026-10-14 15:57:43.402731+05:30	\N	\N
196	Z428	gAAAAABqz1kfed3oV1ybe042A00TZzPp7R13cTG27_612XREFsLCp086jvVHmCwkvzajkWeLlQ410OizssEFkiEjw2KBLfaUlQ==	20000.00	10000.00	NYC	2026-10-14 15:57:43.425248+05:30	\N	\N
197	Xc300	gAAAAABqz2RRufTaAwSbzO6P7exhECAiiPKLCIaLjU5APAecGtqU6DXYnpHNvvPgrae6yWOQRpxyxouQdTmup3sEJGatLyRvDw==	5000.00	10000.00	NYC	2026-10-14 16:45:29.824258+05:30	\N	\N
198	Milk991	gAAAAABqz2RRVlnPT0MfSHxfW_4K5-DaQYgNObcWEQicYvk8UFmnJE2OTgB0V6-kMxpXaCbCkf5RZgESk_HnnUGSA04Glns9iQ==	3500.00	2000.00	NYC	2026-10-14 16:45:29.853261+05:30	\N	\N
199	Boc115	gAAAAABqz2RRmemnI-WBLPXFT9KT5BtyxNUlsIqTIEQkZ2RjMHKoBpLXolzMXvCLjl4FMnX5399pz-267tbIofJYOKw0wMDIQQ==	5000.00	15000.00	NYC	2026-10-14 16:45:29.869383+05:30	\N	\N
200	Ag701	gAAAAABqz2RRIefih2_Pl2S2mlMWldc0n4d-1ESird0m-BiTtVq2RCYSlN9idKI7HkuvJCMabbIe6HVw36_sY0N_gY_H0ZkcKQ==	5000.00	4000.00	NYC	2026-10-14 16:45:29.885173+05:30	\N	\N
201	jack18	gAAAAABqz2RRVRIPBzOYASSEE5MqdnRsBCFitGGL92IXBNrb2E3RgyQAoerq9Yh-jsXAl6XYDy4dAqEpbpnzhM46Q3oSEIV6qw==	1000.00	2000.00	NYC	2026-10-14 16:45:29.902469+05:30	\N	\N
202	Xk352	gAAAAABqz2RRVpY3X5uisu_LQORabLNKj6pIXO3vD8oRheVqVN7WTD_4AS1DB10w3DRBTaherYo22yFZQjJFgmID8vphgu-vPA==	5000.00	10000.00	NYC	2026-10-14 16:45:29.921006+05:30	\N	\N
203	Kog4004	gAAAAABqz2RRSmEti67Hp1aYE1g-tIwOo9fFi3ywsgpc3ECIHcJlESTjyvShin7DhjzIDODCy6xxMUYBo_p4MIJ9aCLPCc7R_g==	2500.00	5000.00	NYC	2026-10-14 16:45:29.937548+05:30	\N	\N
204	31001	gAAAAABqz2RRW2M398pERjNozuTe1J2AXmPVIrgc_vXfnP9fXrb-udaSKrZ6jKWCEslNXT94YJVileWbMPhwAN-mZvxnMEo36Q==	10000.00	10000.00	NYC	2026-10-14 16:45:29.954887+05:30	\N	\N
205	Ford101	gAAAAABqz2RRjQxrtDYxrAcE_lfWNXkEi31COCQuQPi71Ozw8qXYMx9tXeFcKTl2of6F5fpajgXBcX9nSbjC6dUceWwFQ-7gUA==	10000.00	20000.00	Brooklyn	2026-10-14 16:45:29.974242+05:30	\N	\N
210	Jr1057	gAAAAABqz2RStg-QSmfZrtyAFjNtxrT9OIxRfMCqX65KOYw7N_nr58hE8Gdc9xg_ZjEjXkmGvyXVzu9QhtpoNfC-mbGvCXAVtg==	2000.00	1500.00	Dallas	2026-10-14 16:45:30.07407+05:30	\N	\N
215	Dd6	gAAAAABqz2RSZTMJc7d9oUj1EmW-Z6MLhzZkdgWz5V1bCPQNCYHBItppFAv9CKhrdj-lc0f9umn9FLlBDjRxCuf32MP3izXs_g==	1000.00	1000.00	Dallas	2026-10-14 16:45:30.218936+05:30	\N	\N
220	Douglas58	gAAAAABqz2RSjl3fjauIsNVqFBH8coxK68w0Pxv4bJim5LRUW4Hyra2LQuirWplg0Q9MW_7mHPkYRnOcIVzyPvi0Eha0NCmcDQ==	3000.00	10000.00	Baltimore	2026-10-14 16:45:30.317252+05:30	\N	\N
225	Lv172	gAAAAABqz2RSRBQ6fFBqzBrK8JhwVFHvwN3Xs1jmiZdpNVm2cuL0dMYJ5fKmgciPBfiluCpDLhJn3Rf5uzTHI09MUMSdqtOX_w==	100000.00	\N	Dallas	2026-10-14 16:45:30.412246+05:30	\N	\N
230	Bgg428	gAAAAABqz2RSE0ZaC2LfZLT7fvEgpRhrV8lpWHMm-rH1NPBV1awfxiUAvCYJ1UdnU2KTiw1hIDxgsUSo6reEQW9VksoL2T_D1Q==	100000.00	\N	Dallas	2026-10-14 16:45:30.513833+05:30	\N	\N
235	Ord1014	gAAAAABqz2iMHzpa2DefFjDcdWieTo9oGS-o3awd2glcsm_5lkW_F4GtRuuwz1vzL8FOKBT4q67eN1zJUVMcmGyHNykcattsWg==	\N	\N	\N	2026-10-14 17:03:32.974849+05:30	\N	\N
240	Fc5000	gAAAAABqz2iNTqqKKvlj-NOBzv-pGnkskBFvVyAOxRSiZ9vA2bHi015SR2ZMoX13L2Q6kAnvlWcSVLZ_RX77nfXxnSIE-m4J5A==	5000.00	3000.00	Houston	2026-10-14 17:03:33.063825+05:30	\N	\N
245	West25	gAAAAABqz2iNsVRo_NxAlmlxuPso8WcmMgtUIwV75bMCTEN9yvsaMlm0AMtRvHgPLY25QRgRoiB3sWBBDseenJYiIMkgRZNGsQ==	1000.00	1000.00	Houston	2026-10-14 17:03:33.159304+05:30	\N	\N
250	Htwn17	gAAAAABqz2iNr9vDVIdyuivVsyG0SXn7tllVa4qGzwugDcMkfIpAoQ8uzi_cjLAjmsbtYJTYogg6Vt1hFiW47IqTPS439IcFWg==	5000.00	10000.00	Houston	2026-10-14 17:03:33.344151+05:30	\N	\N
255	Mg43	gAAAAABqz2iNrVec3ihWRSGV8H59tFEFcdNJbB1mpWDEuAfe3NYcNP0Rg5LHgs2zgkOp7y3c72cxeZtKlcw3f3B-q54069gTRQ==	\N	\N	\N	2026-10-14 17:03:33.452108+05:30	\N	\N
260	Nw10076	gAAAAABqz2iNOra-r1Z6z1gywndxoCgC3Q2rTNCTpNiYhxYjpBXyanD1BI4teAwncfZAF8j6JAaPPI7WgPYMw97-WdB-BQMKhA==	\N	\N	Atlanta	2026-10-14 17:03:33.546345+05:30	\N	\N
265	Walfin1739	gAAAAABqz2iNx-7lYHZMCadxdJRBUX6GHo1Qnq9_GhkiMPqjEaS24DFZ8hYHHmbXjavUG1YYP-K4MgjRMUNc4hRhSNLET9KgrQ==	\N	\N	Miami	2026-10-14 17:03:33.642765+05:30	\N	\N
270	Qxcrd131	gAAAAABqz2iNrsNi87lyaxkyRZA1Wx6y5ueLWUupbqGaFq-aKfr2riYfNiwEl_A_amdTv1MvvCq6u36i2q6Ovn14DzF6XMN5YA==	\N	\N	North Carolina	2026-10-14 17:03:33.735131+05:30	\N	\N
275	Bltz10078	gAAAAABqz2iNAyOr0-Lv5VRK2G9LK5Nm0Zv_Wwa0bkKjwrSswH60hzn7Y6DkE7ggLOCtG-syqt3L5B2PWRP9RkG0Kp_TbPBI_Q==	\N	\N	Dallas	2026-10-14 17:03:33.83344+05:30	\N	\N
280	Jb2152	gAAAAABqz2iN2Tb3mlt4iJbUtiVvKhtFFvDuuNuH5LYSOutA8Q7kWZafXuArLVNk3xEPMt6TqIj-ALlIDsqA2hhV2C1ec8dhUA==	\N	\N	Miami	2026-10-14 17:03:33.931105+05:30	\N	\N
285	Dae513	gAAAAABqz2iO1P-yfPXmKMwaSNUUlYEv4PVp_w7AQSLSXzc4dKw00Nh-hgOkXLh3qm7H1EU1GVJ-vmD_a3ql48jmMnbe5mAoNg==	\N	\N	\N	2026-10-14 17:03:34.02727+05:30	\N	\N
290	Tn320	gAAAAABqz2iOUazWA2XbwmHebDtLXSFK-S158IiArxTjt9_juqdSDHlScUZttqyJxlK4g5WBciLUThJAG6zr4eHgiLYwuhaHWA==	\N	\N	Miami	2026-10-14 17:03:34.124219+05:30	\N	\N
295	Tb356	gAAAAABqz2iONaMbFYRQMOnLDW0q5UwV8c9j35wH9MxldPUe0195_qkPN3Z58TdHWl5-N9DW79Fgi339dDoh2AW5idDMzFdBfA==	\N	\N	Miami	2026-10-14 17:03:34.224376+05:30	\N	\N
300	Kcc1	gAAAAABqz2iOveXUyMXs5eZ9Bbrf62y0UQ096yQgoHtQNsxVIiTuRcmHDfegpV0oNKG2zTIcDJR8BT8Og9D2p9MsOO8u3IlFRQ==	\N	\N	Alabama	2026-10-14 17:03:34.320567+05:30	\N	\N
305	Apo102	gAAAAABqz2iOgAY5eWzSD9Hrx0PK9tL3ePPEy4KCjbH1bUMZEhLM34V5HKLZ3BPlX8PZcDxqRTWqLfkj4fOGfgfJcNkq6gGxKw==	\N	\N	\N	2026-10-14 17:03:34.420129+05:30	\N	\N
310	9465	gAAAAABqz2iOYzmi3_XaEE08IdYy4YVExv5WFTw0MMnHHuPhK8mxEwOWi2KLZWXD-qLGQN767_n0Y0o8BzHcnZNn7s787_C0gg==	\N	\N	\N	2026-10-14 17:03:34.517599+05:30	\N	\N
315	Trbl378	gAAAAABqz2iOWDug-eHJGjShMVoSrbqAMPjbn6FLJeKkc4-H-XRMGdKCs1_IhXUPYCnwud_2rANGa_ssel7kuZ6JSLxlE5fn3g==	\N	\N	Miami	2026-10-14 17:03:34.611987+05:30	\N	\N
320	Trbl372	gAAAAABqz2iOYS84ZlhfARcNDBgI3HR5ydujpOk78FwCkA3lNB3wJ6InJoJyJf2IWtNCFXUEu3-T7jqTovrr8o5K5L0GIJugZw==	\N	\N	North Carolina	2026-10-14 17:03:34.706484+05:30	\N	\N
325	13-729	gAAAAABqz2iOq56h5uGGJcF6uIY_W2-YUwl3Q-u8zfygB3l2NP0UpcCekFYwjJd6U_j-mbRtrBRBWHakiBa0dEhklyCk-F7_nA==	\N	\N	Atlanta	2026-10-14 17:03:34.800174+05:30	\N	\N
330	Gryp078	gAAAAABqz2iOpTppB1t_cR3U2-0EsinLBki4PYRyfoCLo16mcM2emT6sFKGClfjh68lzIQoAxunHnHsdmOCpvW-NMvNmJ-bLFQ==	\N	2000.00	South Carolina	2026-10-14 17:03:34.896703+05:30	\N	\N
335	Kaf265	gAAAAABqz2iOlptVH3RrCZ0e85GfNHKwj7VEa3YOOG6mzxq6lfBVIXWZAejQcrlIpcmfLb9wSlDnGZJjK7zQfJquLDHIVROPmg==	\N	\N	North Carolina	2026-10-14 17:03:34.996868+05:30	\N	\N
340	Zpt843	gAAAAABqz2iPBc0qEEV9CBawuHkW5OeGVsdeJv0XmuAVTMGjviI_nIybPU1JSavvt4lzpWSykbZVqTwhqXdrggp8IH85FjRNvg==	\N	5000.00	Miami	2026-10-14 17:03:35.101879+05:30	\N	\N
345	Bnt107	gAAAAABqz2iPm6JD5cw4aPMNlZ7HXcA8a_LWU-LJ9m0_TNeud8bmjsPIhNC7-h_ZY0lkCArWy9xVJg_BUiQqgsvgOGcNsROOJw==	\N	2000.00	North Carolina	2026-10-14 17:03:35.203664+05:30	\N	\N
350	Bnt109	gAAAAABqz2iPJ46LI13ePASpU1RPnTCHpWykmjGVIF9km-ZqQemvFefALe25MJFVOoKrT9ETwD5KFBXBfm0-VgIM7q_tuE47ag==	\N	\N	North Carolina	2026-10-14 17:03:35.311183+05:30	\N	\N
355	Gp44	gAAAAABqz2iPaqJdqcY_LhuIN2QHUBTLTb3VIugwa3FWrmJB5tyAvT8QklTP8edZeB5ZBfpfcyswxYvZr-Fcm9My-HJDALPCsA==	\N	3000.00	Miami	2026-10-14 17:03:35.414554+05:30	\N	\N
360	Tig101	gAAAAABqz2iP4T8dfPvOb3zfB-aaUSqxUrbRL9QMLAs4gKu3XJSCgtyhIvwRyZe9TrLBh1DCq-olk_gxdxu5ocWDYSJ-KPvYZg==	\N	\N	North Carolina	2026-10-14 17:03:35.518259+05:30	\N	No max win
365	Jh183	gAAAAABqz2iPwG6pFCcN5AzVWE-nu50RVejq--t2UBm85hdgOXUOmdZNqD-Ba0P0LkMRcQ8zl1HhWfouowsQDpWxzGtfVaRVRQ==	\N	\N	Miami	2026-10-14 17:03:35.620229+05:30	\N	\N
370	Jh216	gAAAAABqz2iPIpbqEfYvd7Wlllqdk_S4JY0Gyiwi7lYBL2srBYLkZ-4TSSvlUkFyel8hrMNOXfYV5MLaAKfLO59DiclOEc8w9w==	\N	2000.00	Miami	2026-10-14 17:03:35.715779+05:30	\N	\N
375	Jh207	gAAAAABqz2iP1UsOm0m4_Zt1XT-zemnoNmd_eU3G7_9U8-sY4hzClOaA4abhWG8Zn_1R6w5aBt7dS_9yUgnseC8Pkq0hIHImSg==	\N	5000.00	Pennsylvania	2026-10-14 17:03:35.809568+05:30	\N	\N
380	Trbl371	gAAAAABqz2iPdNLq26eT8aHuvLW5hOOnly7DmCuCWEexJCE4lJQ_CbsurpALI8uG_e6x--TQv3c5F3RM_q42Hm7uyhvgyjbvxQ==	\N	2000.00	North Carolina	2026-10-14 17:03:35.907405+05:30	\N	\N
385	Willh610	gAAAAABqz2iQ-pEsppMXB1M8NjvgHFhiGNrukQkJCGVRbuNB0GhbWRT2Vo86Bgy06ZowCPEQ_LuhVU3hs08FFIV11PWkJHs2NA==	\N	\N	North Carolina	2026-10-14 17:03:36.005925+05:30	\N	\N
390	Wc22115	gAAAAABqz2iQyCGPnAv42YbjxgmJm8MZX8WcTthNbfDl7khoOEKJ_vj5qfZ8wvb4sEBKXETn-hwkepCnn9DmZg8SCUy22YPfAQ==	\N	10000.00	Miami	2026-10-14 17:03:36.104899+05:30	\N	\N
395	Xjg4546	gAAAAABqz2iQCZnVf-h4i9brxegwkVDLH8nTxIowOv-1s2UgJU2Mn6wm30Oadaae7d15m75xT_49PZfH7c0ADRWt38tTY8SRkw==	\N	\N	Miami	2026-10-14 17:03:36.20217+05:30	\N	\N
400	Cat6712	gAAAAABqz2iQcBcraj_u6VKgDWnSSRbxK1ZkjHryAebd5VGM8we9JH0J1ScNzeopHT0BAnt9P-a5_fMeL_thMGO_2B7MCzp8QA==	\N	2000.00	Miami	2026-10-14 17:03:36.299115+05:30	\N	\N
405	Trav130	gAAAAABqz2iQxHdMjxodSDM9p9-XPwQ8kp7yxdhohUZPKzWfKxNzjlzkiq2q5bUL_E9FLhDPDJ5WVHizTcefWdenmLSkSYW06Q==	\N	2000.00	North Carolina	2026-10-14 17:03:36.391944+05:30	\N	\N
410	Jb2166	gAAAAABqz2iQWu1eiP8O3UzfyDqkXoxzk0GBVDFSouwByiDNvPec2EZpeEfoBldw7ai7D-kJcpe7E8M35CjwqDhMLY1e7-pzDQ==	\N	3000.00	North Carolina	2026-10-14 17:03:36.487512+05:30	\N	\N
415	321	gAAAAABqz2iQDw7crjqVvQFUPHxswIjWBKgVM2L9gPAJb8NXPc802xUzF3igOpv3fbQW07ZwBgflGF6qhrSIXZDI0cZd7re5YQ==	\N	\N	Massachusetts	2026-10-14 17:03:36.586771+05:30	\N	\N
420	Gcl206	gAAAAABqz2iQ08ycdCB6lBhrWj18-pDx1-yphhAaHQ8DlpMypX-E-lsgobm-Rb7CjfoWKctVbWZxKQXOdLfFeE8rjtiObS9_4Q==	\N	\N	Washington Dc	2026-10-14 17:03:36.68373+05:30	\N	\N
425	sn133	gAAAAABqz2iQqv7G3PFOP_4zQjoKeQTc5gjQdBCFYKDP0_NvdErdIaL7K3bcxxmR6o3oUZts_zJtWgLnvdGMj_dWt0jDJgfL7g==	\N	\N	NYC	2026-10-14 17:03:36.779498+05:30	\N	\N
430	Dj1040	gAAAAABqz2iQjoeO_nHuX7v0aDTdTI7Wc5AtFBMC_g2LqbEuguYItH1sOLQQZJ2lBAD_u_QjXjFSNNjChNBRx--hvyVgfYa7yA==	\N	\N	Alabama	2026-10-14 17:03:36.873476+05:30	\N	\N
435	Willh609	gAAAAABqz2iQ3ol07EhToLl-CRYvcUVZX3ks-LCiSC91ZUoLwyAOEFhjUP8_NPnkg92bHf69IxCRXH37ryrG2Zl-E1zwQUWgng==	\N	\N	North Carolina	2026-10-14 17:03:36.967429+05:30	\N	\N
206	FD12	gAAAAABqz2RRQ3EZ6GagnzcAL_clc9PDR7mokvLmz2zt6WPDMdAO538gZXuYR406lf-0bG6QGexAz_U9xxsZRVd6bjjvK2DDDg==	10000.00	15000.00	NYC	2026-10-14 16:45:29.999394+05:30	\N	\N
211	Dmo5	gAAAAABqz2RSZmJJYv3nhZTP3d84ta66CXO8v0TWJbUAK_bDKd4i35LC1UcbetHShv5YO6yZ9iU2T8OQnSyMY8oFtBCANoi-GQ==	2000.00	2000.00	Dallas	2026-10-14 16:45:30.125881+05:30	\N	\N
216	Ao326	gAAAAABqz2RSwvQ3zjzgzvMOyTtm_hW9eIlz3IVfLjs6QZAyk_t6ShGu1fDyzE6_IANtBHQJlFU-dAqtYsyebR3hCUvR7p2xcw==	1000.00	500.00	Dallas	2026-10-14 16:45:30.237113+05:30	\N	\N
221	BC156	gAAAAABqz2RSkEEFCL9IR9QLU8awEQbu5t0sHF6upPSGq7SDffsTPUllMuWsiqpf1ws_9RhaKDJ3jkBZfMa0ZCF1aJD-VGlhDw==	25000.00	\N	\N	2026-10-14 16:45:30.337168+05:30	\N	\N
226	Lv173	gAAAAABqz2RSzXYmNa9AXztWll2jlm9YXeiHY-7THaJdfSLx3rGFY5k9qfhlcSIi5IoTufFdev3rzXs1uQrgxoByRJkPfRA-TQ==	100000.00	\N	Dallas	2026-10-14 16:45:30.432898+05:30	\N	\N
231	Bgg429	gAAAAABqz2RSlUq3FqLDp_Y2pWGNP704Yrqi1IZ-oeJEdHw_p7Zddzm16mArwCX6aV6m5jsEmBQEjscSAGwihS2edF56ylPPGw==	100000.00	\N	Dallas	2026-10-14 16:45:30.531654+05:30	\N	\N
233	Ry120	gAAAAABqz2iM0WTk-nWr13kIjuxEb-Zpl2lgBtQL58-5fCnjmyGakGQMS7_L7POtwjqKWBSVGi1sNmcXTNcbkD8y4g3IbDpShg==	5000.00	\N	NYC	2026-10-14 17:03:32.930371+05:30	\N	\N
238	Gtr1001	gAAAAABqz2iNvB0mcywYtxnu0R9SnD4R72EYz1vRX84jCfauLZ1iuBXQsgBEA_3D8XC019Qf-1O4NP3MU9ioMN5f6JaJo93E5g==	5000.00	\N	Houston	2026-10-14 17:03:33.024959+05:30	\N	\N
243	Tex2506	gAAAAABqz2iNXq7sXREQKuj-5DBTJIvq_bgKCE93rJeOE-vyFnd5yR-IX0P-ubdAN4KFUVhNb-zJXlBPNug_7n9RYK_XUMgvnw==	2000.00	3000.00	Houston	2026-10-14 17:03:33.119647+05:30	\N	\N
248	Htwn26	gAAAAABqz2iNp5btH8Wsn3IbzaykdhfAkHFXKvJEk2eh06j1K60XJ-PLsHQ52dWOuOGIf4BDz_uO9rlBDqa_fews4rGdj1KLMg==	5000.00	5000.00	Houston	2026-10-14 17:03:33.284608+05:30	\N	\N
253	Her27	gAAAAABqz2iNrbAWMYOO2NEUu3UxEUGr6OxK8cbiguIQ9r8wdi9E9EV6x36N8mvR3oaKxHXx2ZZgIpzeOsLqGqJ2xpLE0P9HnQ==	5000.00	\N	NYC	2026-10-14 17:03:33.41296+05:30	\N	\N
258	Teab04	gAAAAABqz2iNlQmeLSazwd0k3bsNpC_wOgEfEUV5ewlFoGBfI3EStTjBnSPlFMAiJgr7EsZ8OmnY05y4vR8L5tZCP4J5OutfJw==	4000.00	\N	Aiea	2026-10-14 17:03:33.50754+05:30	\N	\N
263	80883	gAAAAABqz2iNVt0iJsJUj4-F-Tv6Tg9jWufgO47KwRS5fIk1UUQHqEfL5Wp-99VjcChBVIWsmdIkg7-U_swCegZJAJ8ZpoL19A==	\N	\N	Miami	2026-10-14 17:03:33.603382+05:30	\N	\N
268	Gf101	gAAAAABqz2iN-yVCeuz4P9yaxIlU3bVFb187Ai79uamTZav0daX1NgRsSi2vyUO9W7s6XldjCxgFS_W0dOV4kZA5QD1SeAFZkQ==	\N	\N	Miami	2026-10-14 17:03:33.698103+05:30	\N	\N
273	Roa7	gAAAAABqz2iNJ-i3K0XLTF-3RWygn2YaJNBjB1Agter9LmL8rS1NC6TaqA-kKunw-O3GnWgnVrEHBdCYoz6qHCHQNK6EnSSaug==	\N	\N	Dallas	2026-10-14 17:03:33.79512+05:30	\N	\N
278	Cf220	gAAAAABqz2iN30qJL1yytwdXyh-SAABHlzEi0oRwAmr6TdB9AnY3WQPcYEBiKir0tRPEjdtUQcPViojhbLvqAVhZxjP9dKkGWA==	\N	\N	Miami	2026-10-14 17:03:33.892275+05:30	\N	\N
283	Sgold5	gAAAAABqz2iNb2__Acpdo0VGLNbQ-GAFvMCVOhfrozqeeMtV40oUwLg12i-hvJKxc_BjPmfWQrJlyrlfsqgyAgjp6K_573TY1g==	\N	\N	North Carolina	2026-10-14 17:03:33.988213+05:30	\N	\N
288	Lars262	gAAAAABqz2iO95k1ineXP4MHGLJRf10NoICUJ_l9JArD6N_bAbA8-5KFXxQJ42ud9yHVrJ0g0F6nEPKYQvOoNq0LjkOa_s8b7g==	\N	\N	North Carolina	2026-10-14 17:03:34.084839+05:30	\N	\N
293	Tb382	gAAAAABqz2iOknZS-T_61jXH5wZ0DtiAoOgrz5194X1Y_HpzXqT5Ccvw2TK9UNaWldBN3O9sDuxlwA5q74et0MjJau_FSZ4VDw==	\N	\N	Michigan	2026-10-14 17:03:34.185906+05:30	\N	\N
298	Zpt855	gAAAAABqz2iOkp5S7JFMkBreMyCWzH93NaxlgAmFssngBPSrTlNxeOGM8SBwglcZWfZdlO_2bUAR8W2cLUVQtm2YFaSIzs_aFw==	\N	\N	North Carolina	2026-10-14 17:03:34.28282+05:30	\N	\N
303	Apo100	gAAAAABqz2iOkxWil4EjDoVDCm1mSGSwEw2OOY7MpcdslcyTXtMrGZkxCMLNNBOaKQdoTraK-kWvhc-Tv-TY3ZQaQyEkiJwazA==	\N	\N	Miami	2026-10-14 17:03:34.382806+05:30	\N	\N
308	9901	gAAAAABqz2iOFRyXF_sg_VpT169MfyZW_Oqm-fJjEaqsSwHeS5xyyUgANxMtws9SV-oUMAm2RtwUtWHMbtSQvZ-9gG4nnrclvA==	\N	\N	Massachusetts	2026-10-14 17:03:34.479324+05:30	\N	\N
313	Mia191	gAAAAABqz2iOovLXuIXolavv0W-4WuWQeH4OhmQqxOB9Wu6yYXqkyDwWF3SbPywZpoxzXbzpIs3y-uwuJVLCUCBXvq5a1YiVGg==	\N	\N	North Carolina	2026-10-14 17:03:34.574278+05:30	\N	\N
318	Trbl380	gAAAAABqz2iOPNY7gjmnEtIUvIBUf0LozPelvaKWTEBKldSt3PCzshrECYpeKRiQpOxdCpXz-aBeuLUJq6IQ-2EIGVbkr_lUyA==	\N	\N	Miami	2026-10-14 17:03:34.667949+05:30	\N	\N
323	Whale252	gAAAAABqz2iOhx3HFYuddW1VALC2IGgetqKxrOR1xwRnBBiNYTv2gkDpejrnS9YAikgLlkffGJEWix_t2eCnYKp9yuFnKUp5xQ==	\N	\N	Miami	2026-10-14 17:03:34.761801+05:30	\N	\N
328	Bk141	gAAAAABqz2iOp1wftgUIRbZY8iUFqApuz7c9A1qzhDf8-4NM2pI80Cll8rexZ_l7_tfClRD0RFd3imoH54wfwKSruG99rqTTbQ==	\N	10000.00	Alabama	2026-10-14 17:03:34.858492+05:30	\N	\N
333	FL778	gAAAAABqz2iOZWoo9d3U-N8fiq-_LLOmZYsHqEyiNXhAmm01GIVKSNuAIWKqVR8Q2Rrdg_Wp-EPtEmEo1Rl5UWiTCscZrwM6hA==	\N	3000.00	Miami	2026-10-14 17:03:34.957187+05:30	\N	\N
338	dd0098	gAAAAABqz2iPqein_wIiwb2xFxHy5lOQqhnRtaWEXCOOoSKL2KrRuc9eb8YYm87Bd53UozC3kjHGDx6sGIv4StbI2uDZzCmhrg==	\N	\N	Miami	2026-10-14 17:03:35.059702+05:30	\N	\N
343	Zpt845	gAAAAABqz2iPrS0RX9s9hCJnC6O9NkKNYEZFgUF9YQLg3jMBulEPg-XRDa65SY-wsNsF_cWcDcVet-NOJ55ImRk_-_a2jKevFw==	\N	\N	Miami	2026-10-14 17:03:35.161115+05:30	\N	\N
348	Bnt501	gAAAAABqz2iP0wG3u76aQ388zgZhtgedOKwpz_T8taZ5PPQeBN4lwhqrhSMSDWoH2-gNn53-I0jEihdvVTm0vuJgl4UTgAFQCA==	\N	2000.00	Miami	2026-10-14 17:03:35.268057+05:30	\N	\N
353	Giov227	gAAAAABqz2iPNWmY20pIVWrnagLp0_LYFgAU6ueX9kDYZa6mJntyZ5tLIIuqZOMqUefWo8ytPZfyi3NamMVWCeFO899YdC-KQQ==	\N	2000.00	LA	2026-10-14 17:03:35.373354+05:30	\N	\N
358	Tig111	gAAAAABqz2iPYDRbVD6JK65yJlVo5OU4XnSeTo6M02bCs635H--w7riI4DHSVunpuGSf-TByApmtjse7PVPcMQOSx0Ky4W8MWA==	\N	\N	Miami	2026-10-14 17:03:35.477009+05:30	\N	No max win
363	Xjg4531	gAAAAABqz2iPLxBhJdYkCAtl2_Za1evJkOQT0fo4YQjDsKyEYLO1MNPDKX3sj8qHmWkYOFTFU1ou8UfhkIhwGs8TxHfx0CXGpA==	\N	\N	Miami	2026-10-14 17:03:35.580139+05:30	\N	\N
368	JH172	gAAAAABqz2iPV5oTP1lsGqK4z9NsWg3Wg-AIuhmS1iir5VsNAj1uSSWXLHHpYb7lvoBy4aK8z057le-OJCTsNjtAwm6yYmMQ5w==	\N	2000.00	Virginia	2026-10-14 17:03:35.677514+05:30	\N	\N
373	Jh211	gAAAAABqz2iP6KnaGpgIOnranUf30Aoz7P6Hdc8iUg-bugJP5JC73cCX9bl_7tarsJmZPgVQfyZ2pKRDLRy6tF2nPQqfH61pSA==	\N	5000.00	Miami	2026-10-14 17:03:35.770562+05:30	\N	\N
378	Mia171	gAAAAABqz2iPufvQaLaPtMDFPCl8w4yViqNKBpRwNYRQ_T9doP5Hu0cvuTQldzgwv1Ud215iYJcDtghztIpyfyREYg0PL48j8A==	\N	\N	Miami	2026-10-14 17:03:35.869313+05:30	\N	\N
383	Dak21	gAAAAABqz2iPug7LjJlWfBx5mdQANScqKssNKQWzR-lYBoe9tpMMlxum3fwr9XeN7jiBC10sR8WnMN3brEzxsfVIA4k4kzGVZw==	\N	\N	Miami	2026-10-14 17:03:35.967659+05:30	\N	\N
388	Ss16	gAAAAABqz2iQ_TFpv60o5TCxvWompMOoggzfJBObibU0YjS6n0xqiLTsJfSbDA6l1nwrhQv6ZEWmoAJLRYaLa-4DKPK6B9wXjw==	\N	\N	Iowa	2026-10-14 17:03:36.066735+05:30	\N	\N
393	Pan940	gAAAAABqz2iQb7cOoABc0AZECScdkV0TY67lNHc7EshAXei9fQrznAaBUr4JmUmCiXsr2p0fyI1yEEAsSYGXrR-0kDalG57qrw==	\N	1000.00	Miami	2026-10-14 17:03:36.164275+05:30	\N	\N
398	Xjg4550	gAAAAABqz2iQvi9IJ8JugStpQkpLQNAUNMQW0ORjSt1oIGMtfYm4vJkgNTJe2112plz9M-elkcmBPibtDjpKa8idAkL9DxhfBg==	\N	\N	Miami	2026-10-14 17:03:36.259666+05:30	\N	\N
403	Cat6708	gAAAAABqz2iQmDtTtmUWxWq5lSe9xCo4t-K36JfIvEr03IB9aiBF_3HOcwax1CHJRrxNdhVX4aeOko9zAAaSsr_8E5-eZGMpyw==	\N	3000.00	North Carolina	2026-10-14 17:03:36.355167+05:30	\N	\N
408	Vin123	gAAAAABqz2iQn3WAhZ01nartkIUsWGn3yYwcG2wwbv-yljMWno4upsfDcL2UqpXRFGjdWf93zRfb-Ud8RbFCBwG0jnlU9KdGYg==	\N	3000.00	Miami	2026-10-14 17:03:36.449412+05:30	\N	\N
413	Ath148	gAAAAABqz2iQU1h1sM1VD5y6VLpQXZ-wLuEiBBFkOF5WripQFXH6ybWLvqABPUUAZxztBAs_XW-XoOIzLoBEJk0Y78ZLldyAmg==	\N	3000.00	Miami	2026-10-14 17:03:36.548358+05:30	\N	\N
418	Apo107	gAAAAABqz2iQatwSslOITeTqCZCvG57tPfaqQWdWHnXF7bbGiB3qroX-GuRaXBNyhYucW1onpnThVFEpjvWjbWj0a-wPr19SBg==	\N	3000.00	NYC	2026-10-14 17:03:36.645257+05:30	\N	\N
423	Ceo1283	gAAAAABqz2iQkzEeO9RDsFG1e-bahh61iDsKWKFoG22Hb2CAPDo7ynXJbz-sKGRd7ouoAC_0lfEq44uTpzChzSYZ0MN6udk42Q==	\N	\N	\N	2026-10-14 17:03:36.740814+05:30	\N	\N
428	Bal90	gAAAAABqz2iQXuuLLCztaOufpVxqSFEcwhBlUen-Bq88h98Pxz1PsQMh4dtBHbwVg5Q11OffbCmdHohKjxrFNVXh27tK2bsfgQ==	\N	\N	Dallas	2026-10-14 17:03:36.834362+05:30	\N	\N
433	Justal	gAAAAABqz2iQDgzPtWX-c83FiJrbPsYgB5dPiWmWsaPO0R0bN3c1kTo9Kgi3hkj2CMIOu0ggYAHFOgKCw3JEadUo34M-JoJv7w==	\N	\N	NYC	2026-10-14 17:03:36.930262+05:30	\N	\N
438	Jh195	gAAAAABqz2iR4VUsXB0iSXFXdDrWUxcuMsi_mCbi9WzeLyTT2XpT3vaNeqxjNmIbXc2-y1wp3KOquK2UIyTc0E4mYwxyqhZkyQ==	\N	\N	Washington Dc	2026-10-14 17:03:37.026028+05:30	\N	\N
207	7262	gAAAAABqz2RSq0_H97DvHDl2ocUhneu-OvNiEjvcE1yV4dC5SbAKuMaBrIJALFMI5Nr99i62IZD8NESl5cn7BaF2Urf1kKlzlg==	\N	\N	LA	2026-10-14 16:45:30.018791+05:30	\N	\N
212	Dmo13	gAAAAABqz2RSiA0ZfFBv81m02mBLJaIcBm35qMzPNkSWHjKHhmnv0MO_Mul-04eVviW90euvFQn_3ElFcg0rYD_wcNq-PmUXWg==	2000.00	1000.00	Dallas	2026-10-14 16:45:30.153332+05:30	\N	\N
217	Ao283	gAAAAABqz2RSpy_02whAJtOofjt6u-WNoMAeA2Gf6OTWDBIDQcYBwRsVyM2JqFB-WxufiofINJNZSlwC7439QnPuS0xACSgGPw==	1000.00	1000.00	Omaha	2026-10-14 16:45:30.26118+05:30	\N	\N
222	Ppe102	gAAAAABqz2RStLUidAZ7MRd83axdnstAox6xCOK475tcRnACVP4o60Ldfg4AkNAw0AHXADk6QFl3naaK_kfETHbiBRJ3bQOUPA==	10000.00	\N	Dallas	2026-10-14 16:45:30.35417+05:30	\N	\N
227	Lv174	gAAAAABqz2RSBbS9hoRqsg_XiEeOsdl41APFRVZNMvoo_CtXq7p0gxSGF52z0x5mENMFGcvWcGlNN73SUxGnLxwjyINN-yB3fg==	100000.00	\N	Dallas	2026-10-14 16:45:30.453776+05:30	\N	\N
232	Bgg430	gAAAAABqz2RSkOtMCjuMGnt7KMAIwwtdkU0hpVukDXajGagv3eqwwDNHrapVZ3IqgmLoJnUgwxjiK6U91yXdo1x7muG1pq8QOw==	100000.00	\N	Dalas	2026-10-14 16:45:30.550442+05:30	\N	\N
234	Jul304	gAAAAABqz2iMFuDUAAgyrvdBD_tMqJODVZjovCdPyiMXjdbUiSHmk-ZE15Dh2MwJ8p8IPuASA5QwOXswlJpXJ-7XqTXIrlvlKQ==	20000.00	\N	NYC	2026-10-14 17:03:32.95452+05:30	\N	\N
239	Eyg57	gAAAAABqz2iNLJLAWyMHV98LriBaYS6y9PbEtYk2nz0rhV2MNGe6SJNfrZSAp7wIUKayEJVrKaW_MkN1Od7yVS6Qi9Hpo5yN5Q==	5000.00	5000.00	Houston	2026-10-14 17:03:33.044004+05:30	\N	\N
244	Oc15978	gAAAAABqz2iNdcUOUak9fRIiGBuZABNCxPmqSONEEz42cMzj1Er-JT0lJ7CZ1v3ELOOtPlnczEbhStcD3LtSpaMAlWCmilzj8Q==	1000.00	2000.00	Houston	2026-10-14 17:03:33.138434+05:30	\N	\N
249	Htwn18	gAAAAABqz2iNYTgbP_KIIPg-vlObCFSopoIio-_JnkVX5TiRFrLqHJAvkAkUV__VFffEo9Ou_5F_vME7-aUH9feJTCawuSIf2A==	5000.00	10000.00	Houston	2026-10-14 17:03:33.32031+05:30	\N	\N
254	Dime89922	gAAAAABqz2iNUviwXpwwBH9K7YiDVi0SFGKbYdGydorwoaxWSOKmUuDakuECJC9L_KizizyW7rUhZivH2cUnkBzvwxE_g6lpfw==	3000.00	3000.00	Dallas	2026-10-14 17:03:33.432544+05:30	\N	\N
259	m8610	gAAAAABqz2iNa_rU8XsFVr7pN8D-CnspduDTzdVl-q-ARU39XS5cXF92l1A_iUSxiJuNrtrbstnw9uYWZ5Ry6kVU_1Bcm5-Eaw==	\N	\N	North Carolina	2026-10-14 17:03:33.526406+05:30	\N	\N
264	Camswi1720	gAAAAABqz2iNtAC1Hb5LEWdN8ghktwAmi4U7X3N-F_YTF7olnGje4MeztddgGcmSCKnIOiD3fDKbaXl34UYcw92a6VPK5AVMaQ==	\N	\N	Miami	2026-10-14 17:03:33.624516+05:30	\N	\N
269	Qxcrd136	gAAAAABqz2iNQnpBSGJ63iNlHhRMKZGsjkhy0cIhW31fNj3PotsfGTnHQlTYdxLndsobggSpS_ySobmatRq4SN6aeydogPqnWA==	\N	\N	Dallas	2026-10-14 17:03:33.716225+05:30	\N	\N
274	Mm303	gAAAAABqz2iNh-Faj--DiIyr8gWyYfmNS2PiyzpfXsn9gQrSuaQ11TQfVF8VTEMuPZUZe2FGnrukvm4s3haqqWCCgApq-Onqkw==	\N	\N	NYC	2026-10-14 17:03:33.813571+05:30	\N	\N
279	Bbs023	gAAAAABqz2iNcG4IsMIZl0oAICeAcZq5UGq9ESqoXm-ugfYxOu0-M8txcgdrUY7jI3RSy_RXvOOmi-NB-5INYJ2jJ15c8WUtBg==	\N	\N	North Carolina	2026-10-14 17:03:33.912881+05:30	\N	\N
284	Va115	gAAAAABqz2iOa95O3BAeWpE8Hu6OeQl9Y9dOx9-uPyu_tr9Vmgpo3pVXABn9RJD2ZUHEDhpmrOagbruRbwyTxACA4x4Gx0fP4g==	\N	\N	Miami	2026-10-14 17:03:34.008709+05:30	\N	\N
289	Tnt1896	gAAAAABqz2iOWjQlCcI7lK5HhOfb5I7jxANyXj0uVTlKKSJ1cy_Bo_7plgzW3Zid9nY9d_RsSMXuxi3KSS_w_EZKcNVZUVkWJw==	\N	\N	NYC	2026-10-14 17:03:34.104259+05:30	\N	\N
294	Tb334	gAAAAABqz2iO9v6TjFNbkvt5MyaIGuCVuwRSfsKL40xqfn06NEkFPDidX0x8WF03Xz5SShOzl8fEuz4iVUL-CS2DTyZ4V5n3eg==	\N	\N	North Carolina	2026-10-14 17:03:34.2054+05:30	\N	\N
299	Gsu2119	gAAAAABqz2iO9QRswfSZAEFSbZ0YGN-hdqskwCMnn2XNr4B8x2_XsvQsjUjH_Zhl-xAYCwQkQq7fAx3wO69mYBEQSXrHkiwGvw==	\N	\N	North Carolina	2026-10-14 17:03:34.302431+05:30	\N	\N
304	315	gAAAAABqz2iOc8o4v1VLefYxbZ5dGfBvhzcCUYW7EakW-D6xFUeSPhfB8aAnfS-PUo2yNGvKUaEfORHt-QhJLavsck3rH6lTFw==	\N	\N	Boston	2026-10-14 17:03:34.40092+05:30	\N	\N
309	9487	gAAAAABqz2iOBrAo4CFu4_FKgbw9lyexa_-3FPr9JEoNjfr2i33ZzVgMeFN_V_kxLfe9Ap3BxXCXWzvdkKLVR251twUkZUQKlg==	\N	\N	North Carolina	2026-10-14 17:03:34.497878+05:30	\N	\N
314	Mia190	gAAAAABqz2iOSz7RvBRSQETF2dwZZ0VLqlc6_Nz3YXOP-6IJzF0_lyvAx4rpCLvt3-dnqhKG0u8UB3Pj62-h_pwfZNVN9X_4Uw==	\N	\N	North Carolina	2026-10-14 17:03:34.593852+05:30	\N	\N
319	Trbl376	gAAAAABqz2iOKnKCY019JpSMqxhuyul2uRXdSZo-ysS6dd1eCuMXRy70CQdrEPWKYMJHi74XAvjU1IQFOjTVMXads1x3EFpU6g==	\N	\N	Miami	2026-10-14 17:03:34.685701+05:30	\N	\N
324	Whale208	gAAAAABqz2iO_u_7wpQxJ7V8QOPaYEK1aWAyk9HX2YndDGE1pff3pNeW9kkvgs--jagjWcQKXVfRMVpEiIKKm7rvBX6hd_-Fgg==	\N	\N	North Carolina	2026-10-14 17:03:34.779902+05:30	\N	\N
329	Ld2	gAAAAABqz2iOIWQ42jEP9jmupqEGU-qUJqg48azbyiHS5LadskC1M_4Ikln7nEuC_UDS00M-PCFRZwnitDL0DYZBYlE0XJArGg==	\N	\N	Miami	2026-10-14 17:03:34.878398+05:30	\N	\N
334	Kaf190	gAAAAABqz2iOSqW7kROZX1xyog-hgmby9XrDrsyVmziPw15y6Zl_lPTTxW-Q3wu5JAVxExF8wqoUwFRyETZSBVP-Mt_5BGzTsg==	\N	\N	North Carolina	2026-10-14 17:03:34.977077+05:30	\N	\N
339	Zpt844	gAAAAABqz2iPUumPnWCQ9NoN3CrHwWnNUjm6IpzB5UY9hnOMLXjs3Klo-cHuPaquHEpk-T0J5UUM0d7x6rmqKHjktvIWiiEo7g==	\N	2000.00	Pennsylvania	2026-10-14 17:03:35.08108+05:30	\N	\N
344	Bnt406	gAAAAABqz2iPuI1LUj866vCQLJFykR_UnLSGqCAEDUMwYsVWhEqQahkaMmU8bYUWz-GulTAdIJ60vww_f6Da8HrnS54M0u5uUg==	\N	\N	NYC	2026-10-14 17:03:35.183637+05:30	\N	\N
349	Bnt110	gAAAAABqz2iPnTE6epdXeecq45h2d6l_FSau8LjOTcrMVoF1TRF7H59KL2jFQ3cYK6pWEiEg8OKMCZH5sGfy2NCsnkzOlby2HQ==	\N	2000.00	Massachusetts	2026-10-14 17:03:35.289391+05:30	\N	\N
354	Rpr44	gAAAAABqz2iPRSeebpEukZanwDPI8qNis5nnSMI3m9_vfF4zRw2KZXAFeqg5NSIjlrq3kvC698Zj_XrbJajTsvhT39vzqbK6xA==	\N	2000.00	North Carolina	2026-10-14 17:03:35.394323+05:30	\N	\N
359	Tig107	gAAAAABqz2iPPC_HZ1Td0k-98OYVjK0j2Yl2bguC6zUPYeLb4z89jpy9GyRmxktsJFq4XZCmtQvNTafnCNzP-OkrIaXG6d-yrA==	\N	10000.00	Tampa	2026-10-14 17:03:35.498271+05:30	\N	\N
364	Jh206	gAAAAABqz2iPMjLa0MO73eUu2ae0IHbKdmVasJmDT38LCu1-IchWF9LqKd9j8vowuzcx1hbngxgCVB2c9E4XgMymHDdOiTULdw==	\N	\N	Miami	2026-10-14 17:03:35.598226+05:30	\N	\N
369	JH159	gAAAAABqz2iPBtEfktgNequTgdgBHtJ5sV9FVjA1kMu4EADm9wZwYvhyczU6moEjaf2QUCIRNZJWVX9C0JLQ_EoNc1mAoyI8OQ==	\N	2000.00	Minnesota	2026-10-14 17:03:35.696695+05:30	\N	\N
374	Jh201	gAAAAABqz2iPR10-RX2tHZjZ6VV1JVric-37AgliWexWRbYb_a0iQp04yms2PNm4MSKW29mbbxg5rrCpwmSP6MjjgUvqzJUl2g==	\N	2000.00	North Carolina	2026-10-14 17:03:35.791078+05:30	\N	\N
379	Mia161	gAAAAABqz2iPd-KOGeCWYaewSNmuHvQ20uHHkRgWlQNJEfvEU6AuDpdTyPyffmE8CLASLQNnsbks0m1dTKbyA0xHFt_dGfPxXQ==	\N	5000.00	Minnesota	2026-10-14 17:03:35.888053+05:30	\N	\N
384	Ea756	gAAAAABqz2iP3CpgqI0bbBg3A4Z1e0onVYUEy3p5InbQkDnDkSpl7x7DakMOoCgrJ8RUpTy17PI6F8IE68SkfArlzo6SOE14Tg==	\N	3000.00	Miami	2026-10-14 17:03:35.985932+05:30	\N	\N
389	Tn313	gAAAAABqz2iQ4FfEsM5TFtw649TslNgG6s1LwuEIREsz1R4vou3STFR-2JjkC4G3sUbtFQp_u66snkZoQIUVjizLtI5Iy4Bx3g==	\N	10000.00	Miami	2026-10-14 17:03:36.086687+05:30	\N	\N
394	Xjg4547	gAAAAABqz2iQ2efkbTKlZSQFvEavZC_pUjLKm5aoM4GBzcL9vOrKb43ut-OJGoduZJXTucCE3T-5qp44neJJ35_71OTaw-H9_g==	\N	3000.00	North Carolina	2026-10-14 17:03:36.18302+05:30	\N	\N
399	Cho232	gAAAAABqz2iQrTYRLnPwOasF6qDIHk4K1mafUeyABuasLfcVH7nLOH27-w5t3c_qId_bllAnLFatV-JKuucONsUj9v5kSlmVSA==	\N	3000.00	Atlanta	2026-10-14 17:03:36.279565+05:30	\N	\N
404	Simon125	gAAAAABqz2iQBArhfJdOUZ0vxeaJALOJoUboYrtgFasWiGETH0Saoz9vXjFO2GlbEYTPnEBRdG4qI0eg3PfEJg6B0iRJ1vO7Jw==	\N	2000.00	Miami	2026-10-14 17:03:36.374751+05:30	\N	\N
409	Ethan125	gAAAAABqz2iQ01Sno19owZz5cSYyNbHCs4S8rRZHIjwPIl_isd5W0l5R8FOPnmiZL6IMJ0XRsLY9clL0WWGZaW0tSBnNPOqyXw==	\N	\N	Pennysylanvia	2026-10-14 17:03:36.469181+05:30	\N	\N
414	Apo110	gAAAAABqz2iQ9XF30cLqBZGwwayZQSYh2zuXudooeQgAk2ngGgBIsp-Ock0U3wDTusH1QqyIwF4kjH4FlbgLqJSec2ZuEhfgNg==	\N	\N	Virginia	2026-10-14 17:03:36.567062+05:30	\N	\N
419	Apo106	gAAAAABqz2iQx3B40BNvQjUhNWhpJA61-jhE2jc7_Yqdj8ITtjjD_8sJb4r3owIoiYrqfLRUaMv-cVQ1-Uv3Oa56S9deMvz4Iw==	\N	\N	Miami	2026-10-14 17:03:36.665457+05:30	\N	\N
424	E655	gAAAAABqz2iQaIt08inPKgf1_RhjCJv-lfrdBYpVriZ12RnxNj15OWf3a-Xp8YbO5R-CAoK1m9-2dTFRyQceiPVgOMxHX-jlpA==	\N	\N	Mississippi	2026-10-14 17:03:36.760286+05:30	\N	\N
429	Gh1237	gAAAAABqz2iQ4geTYal2lF2R3WCxQHx-9R99GhfLPjlRmaselWv0t6wu_2iuN11PMSlS2dr7gLCExj5kNy9UqhuHqbRNy0C0tQ==	\N	\N	Alabama	2026-10-14 17:03:36.853403+05:30	\N	\N
434	Sna102	gAAAAABqz2iQEcnWvqacXIrBRN3cagF22gp3zas69DvJiDCmGFFLJqmrpAHjlq5cHHMXKNEgBYWxpBoO4BbRQ8g7Y-UEVEnBHg==	\N	\N	Miami	2026-10-14 17:03:36.949543+05:30	\N	\N
208	7261	gAAAAABqz2RSbakZleXWvvKCg__ylUQg0NHOPXCbYj5UumVxiTQG8X3x_OY-7z1gaFbca9QffYstMWyszUe-xbURSP-0R7oa1w==	\N	\N	LA	2026-10-14 16:45:30.037823+05:30	\N	\N
213	Dmo20	gAAAAABqz2RSyOasm97H0dmGYt-vfeRPqQw0lnsJEKC-0fw9lfrWREjThftq91AVO0LiDvWIEkKAdXkIR45rpm4KphJD2dX1fQ==	2000.00	3000.00	Houston	2026-10-14 16:45:30.176193+05:30	\N	\N
218	Flt006	gAAAAABqz2RSW2Z_2DAWpADXuK89erX8-6C68bRmlU8JUsV1Chw45pxqKr6HQ1UNLfQivNioabWAXpt0SExIGpyAx3kcvBKMZQ==	50000.00	\N	west Palm	2026-10-14 16:45:30.27955+05:30	\N	\N
223	Ppe130	gAAAAABqz2RScYjfVs1Z_Xwy-NLyWFZbGatqFVayMmKQZ7nZ7xg5UiV1JCbdB2HQYX3gqQFJik4c3g6YxrUWGoLRPXtYlUVVHA==	10000.00	\N	Dallas	2026-10-14 16:45:30.375048+05:30	\N	\N
228	Bgg426	gAAAAABqz2RSTZv9rLS7yaMC_TcznjSDg_k39JetSNrnx4Fzb8f3k-iOjhltsMV-hHNgAYQz4ItHKypX9NgQODQJIV4LKCZnqQ==	100000.00	\N	Houston	2026-10-14 16:45:30.474476+05:30	\N	\N
236	Mg28	gAAAAABqz2iMdTjTrExiD1Nj-YRHlfgFBklPxGspCdubIz-PXKvJ88p88arX-9X8LTUbz_7H3swumTtuoVkeFxk8ESvjAVRXzQ==	\N	\N	\N	2026-10-14 17:03:32.990012+05:30	\N	\N
241	Tex2509	gAAAAABqz2iNi9DAsu2oMrqZwVBQwJslKpCwnnnI30pmBanqU_f6Xsae0IOxsizIyBeTEqzFtuh5Y4OwQmVapDkt_sBqHM_uBw==	3000.00	\N	Houston	2026-10-14 17:03:33.082284+05:30	\N	\N
246	Ran26	gAAAAABqz2iNRPLMrX49SraraNWW4V5-f8qXCRkta0Ps2gdPHZCUvKXphi-d7KlF9Wu0L8g-QAl-Zb5sSN15E_JsshPtqz6POQ==	3000.00	5000.00	Houston	2026-10-14 17:03:33.178936+05:30	\N	\N
251	Htwn25	gAAAAABqz2iNk6l7zc_oPbW9dQ0MGAy9yZrfJO-s3_qqpdXRsgnK6pK3o9hoRpNCKdKxTbgqzq2UTo9JMzLyXgnH6vkxp2ORhw==	5000.00	10000.00	Houston	2026-10-14 17:03:33.369904+05:30	\N	\N
256	Shs447	gAAAAABqz2iNe9q4DSVjmSH9ZVrxLejws62U8jSyy8kAWeiWrT0sba3Rzv6id7LqgddPyg8J040SzphgwmNiPa6hJ2kp5QQRfw==	5000.00	\N	Aiea	2026-10-14 17:03:33.467978+05:30	\N	\N
261	Ariz12	gAAAAABqz2iNuhfAWKOqKrcpiPJ-dJvusLDDIXr9EZbfq-xvXkXKC7fuNDEx7MAcWAy0Z2jjcz3Kr203b7e67ApwtjIK6jm0pQ==	\N	1000.00	LA	2026-10-14 17:03:33.564937+05:30	\N	\N
266	Qq114	gAAAAABqz2iNSgxNHePhQc1OMPaPgjdzQKE_dlOgQojXcZ6k5vH6KlzO8JRQtQWxPki98QOv-3fy8rroXrIOg2xkHhDS3a89-A==	\N	\N	NYC	2026-10-14 17:03:33.661341+05:30	\N	\N
271	Hou1701	gAAAAABqz2iN4HHMIF-9Vnn-IyOd9PoSNtQIK2fDcaEdF0e-wRsB3LUQbYSmLuSq_lmRwXs8yqXqOVw-dxd0t842A-MBkUPhjA==	\N	\N	Houston	2026-10-14 17:03:33.75541+05:30	\N	\N
276	Sp6121	gAAAAABqz2iNS8TTqH_KfKuCh7LYMD39ZMlILhm3KVxEDcHnAIgvhUC-bkd6ySrl7_bE0lCgSNlYtdUi2wm1G8A2P3Qeoi-aHw==	\N	\N	Miami	2026-10-14 17:03:33.852512+05:30	\N	\N
281	Jb2047	gAAAAABqz2iNSVEcRgOWOted7cR4Tzupc4R7YAtM95LbWit5prcjL6tBdv9EfK3EDShsnrEnY6xs8XHhkaEZXwl5PGNYqIVLGg==	\N	\N	Miami	2026-10-14 17:03:33.94995+05:30	\N	\N
286	Ceo1284	gAAAAABqz2iOEiYI5gQMeMX4lwrYSLcxlpIUd7LW48vCagfsIrUS8Sb2d2HFYdytuvFbjY-MZrJHA0qzuAwnS8fCC72XzdduoQ==	\N	\N	North Carolina	2026-10-14 17:03:34.047335+05:30	\N	\N
291	W27255	gAAAAABqz2iObfnxmjNdJX_hKXA6rzrMHQbIMDNPCu7P1vM5D15Wjo8sW8FoNxw9WZcHKl_mltq3Sd4l1XaPWPHu3iEHJjiTQQ==	\N	\N	Boston	2026-10-14 17:03:34.145132+05:30	\N	\N
296	Tb381	gAAAAABqz2iO9Q52QHVBwVQFGX7-vX7Di8sS50adX_Ea4Zz0oQVykzb5RE3DJttJdwJ9kmwbMEOyUlBCXSYs0YvUxM7vgVGeLQ==	\N	\N	North Carolina	2026-10-14 17:03:34.243189+05:30	\N	\N
301	Ppe148	gAAAAABqz2iOhFSZxwpKw-_Rf6CgZoO0HSOME6h70pmyZPj1Sc7HpExRGprZbVEeFiP_22AchKAfEC38_LsV8hXTt7g9wB7Z2g==	\N	\N	North Carolina	2026-10-14 17:03:34.34201+05:30	\N	\N
306	Fk5555	gAAAAABqz2iOINYk8RsXks2QJpfpQPBbk4ovYXYEL41wKEb5pom6s0N6aKARW0Ok1KJGszEAOaUvI_C-8RbL_vonNdtaI7YTDg==	\N	\N	Miami	2026-10-14 17:03:34.438861+05:30	\N	\N
311	9484	gAAAAABqz2iOkXysg9lQrdxdwTuQeJZ8UGiUY3OfvokFyebO057g4cARbh0uWg6-NdhovpN-9L-yZxLdZKW1aSwH42_ltKcNZw==	\N	\N	\N	2026-10-14 17:03:34.535143+05:30	\N	\N
316	Mia188	gAAAAABqz2iOHFyLl326WQcvYgn2sV4jTaaOPvPkYZc5BL1PiZVxDZZtqpdefI1pIP_z8e5oZBz1S80WlqlphVPGxJBB7ETXMg==	\N	\N	Miami	2026-10-14 17:03:34.631007+05:30	\N	\N
321	Mia167	gAAAAABqz2iOJPImrYUcIWRXh86RFBKc63tZbykv5bWjPC_9n3P3V9H0Le4wv_Dq8NQsFoJHB1EC_gd1optd6AKw9apFJPsS3g==	\N	\N	Miami	2026-10-14 17:03:34.72465+05:30	\N	\N
326	Sle76411	gAAAAABqz2iOfcc7PxRt6EPGS8ezgD5qXQT3tPguvu5jYpuskQmaFRageBlXn-l6zK_m_n-ecCaJgbBLTdWjmjU61KAeA7uYdg==	\N	\N	Tampa	2026-10-14 17:03:34.818846+05:30	\N	\N
331	Gcl115	gAAAAABqz2iOXQp6Y4SRB_OXpqH7fsWLQ96yC4hyopaQgn7AM_ONO7duUi2yYE9smEPkKQJhLV4hpeAxyxS-6k5ZuBdZ77DYhw==	\N	\N	Michigan	2026-10-14 17:03:34.917546+05:30	\N	\N
336	Kaf155	gAAAAABqz2iPmAl1-wytHy2Tb3QvjJwYIpwjR-xUSSThJzKN1PDnhA1oWEvKVYPJrr5OMSvzAx0Too-ZUEEhaRdKTUJFRTVAVQ==	\N	\N	North Carolina	2026-10-14 17:03:35.018223+05:30	\N	\N
341	zpt850	gAAAAABqz2iP2wDp5Innf-2rpvL2_3YT1t7pEFVzUy5WJ91fmlHOyJ4aZxacxyE2V16-hx2GR4cX_3DnaasHpk3gnPK0uQjmHg==	\N	\N	North Carolina	2026-10-14 17:03:35.121349+05:30	\N	\N
346	C76590	gAAAAABqz2iPUkqFNC6cW8nJ-brLewQBGAt6UNCE_hTAKD6DT6HnHa5_L9exrEEsf2yAY5U6ItUIfWrnOSTYlYNNOT_zZDD1Gg==	\N	10000.00	LA	2026-10-14 17:03:35.225115+05:30	\N	\N
351	Bnt404	gAAAAABqz2iPlRux8FEXwzr6gdpjf0KErPleL9EVhByx84k-uPuYtoXK5jqWQPZ-NFcCQloDH0nM102NclhBozGfFJ3d05GB9g==	\N	\N	Michigan	2026-10-14 17:03:35.332437+05:30	\N	\N
356	Cof44	gAAAAABqz2iPMU2aDulyHe3KhggEJCtNnnsZBaeYhumYWWfNqUAieor7t_Anr1eCf4jj9UitCSEgsOwYJqTJFn4VIGOBhjduvA==	\N	3000.00	Miami	2026-10-14 17:03:35.435401+05:30	\N	\N
361	Bob1021	gAAAAABqz2iPA291z1SEFwGi48lAqfUaBq18PXVDeFTNOW9IpdF8JifTXqQ9-jalBZ-sxq4kPTkRqN4Sy4KkZvGdDV1ewttYqg==	\N	3000.00	North Carolina	2026-10-14 17:03:35.539889+05:30	\N	\N
366	Jh176	gAAAAABqz2iP9xeTtTekWBIzvDwdABCjpvJZfWX0xfvx_065-ShyZ0C0NQtLVpciAgqXmq8p_O0zFHRaz0CE0y1Yer96WXIXKQ==	\N	\N	Atlanta	2026-10-14 17:03:35.639187+05:30	\N	\N
371	Jh208	gAAAAABqz2iPkJILhgOZqmZyjfb7MqMVxEoZfMpcBjPcQN-pTxZPTzQnKDvB_6WyrzZBZ2aVL4tWcXw-SGbtDci2r8AblV5eEw==	\N	1000.00	North Carolina	2026-10-14 17:03:35.733851+05:30	\N	\N
376	Jas1876	gAAAAABqz2iPgb-_7cMtxe7huw1dTjW9gczoKSiSsOVN-FxmF5w3hLgQnQU7ftWUYvXnZY1bijkrKcCnOxScBqk-fwyCGGI5bg==	\N	20000.00	Miami	2026-10-14 17:03:35.831413+05:30	\N	\N
381	Mia194	gAAAAABqz2iPU5zgm0tauOsJ-JBT-GNgGzQsD_fcKIvOAA_xNTjYo8P-w71NGxV62qmXkIQ4g1h75ypYTVRK1rDSPfaBePuK_w==	\N	\N	Atlanta	2026-10-14 17:03:35.928427+05:30	\N	\N
386	Tb124	gAAAAABqz2iQ01G1njfwTn-UxYF5dWje4wxVaqD6fGOcy2JjqvSQH5nNqQHNf59GSkGVM7pYUbphE5C8ccmAyoBzM_Bc6GL0Rw==	\N	5000.00	Miami	2026-10-14 17:03:36.027015+05:30	\N	\N
391	Pb536	gAAAAABqz2iQkx-kFa8k6QLNkkENNjcVvQRLGLjIZSLKxKNCsfMEACII9reqNytctQ0x5DDXvEyoI6_oqws0hG_afX3pp_aWEQ==	\N	3000.00	Miami	2026-10-14 17:03:36.124681+05:30	\N	\N
396	Xjg4536	gAAAAABqz2iQj9_OsG0dRR5EBelNRBWWht_jZy04UK5oUSBwrDLi7xVS7wFnUwjgS_i6Wbnkr-eUFPLn76Gqey5EmB7kHzBGEw==	\N	1000.00	Pennsylvania	2026-10-14 17:03:36.220491+05:30	\N	\N
401	Cat6710	gAAAAABqz2iQ8VFbJKjoA-0R2bqLt3izL3U7mdxJHcQLsGFsG-T_dhyMoPHpN25JtPn_iIGxfZNRGl09qHc4Ac4KaKuM6t0rzg==	\N	3000.00	Miami	2026-10-14 17:03:36.317888+05:30	\N	\N
406	Fsu93	gAAAAABqz2iQZaBV6s3e4beLtUtj_J1rmGHNhYnsTkJI2aBB5OfWD33rvl5RPEmlChTGgPE1esoHK99MyRFSN3jMipSe3RtoHQ==	\N	20000.00	Miami	2026-10-14 17:03:36.411636+05:30	\N	\N
411	Bnt105	gAAAAABqz2iQaHT2Y6xkDeY8j016WqRdA5xhhRS3Z5hTyfafhSpjs0E54omybrvYC-egmIlde-NxADq3-rj0rvOVEAyH6OWtnQ==	\N	2000.00	Miami	2026-10-14 17:03:36.509349+05:30	\N	\N
416	317	gAAAAABqz2iQ9JkGC5kS0qYH07czOBM7RPs9ZeRHvdQRYrBBF0X9-2u3nbWbrvpm14I5H2lfvlv0RrjOkDlnEBqjzRoYkDmW_A==	\N	\N	\N	2026-10-14 17:03:36.604976+05:30	\N	\N
421	Gryp162	gAAAAABqz2iQnrMRX4k9mrbvZsmBDtsFSnOxcfadeq3AYVMgJGKzGqv_BzV7NTg1AaDgRHl8zWZsSZq0YWf7VndSTmvVkUSp3Q==	\N	\N	Virginia	2026-10-14 17:03:36.702785+05:30	\N	\N
426	Sts5163	gAAAAABqz2iQWPy-sECvvZTuLd595CwlcVtB0FiVXZyN6qTlSdrAnDTsRZyb57T0MWVRh6fnwQSquxdH36m3yk_NW0WClkA5vQ==	\N	\N	LA	2026-10-14 17:03:36.79813+05:30	\N	\N
431	Tsa88	gAAAAABqz2iQz37QjtIV7_NO50rf_8CBpNnh5vIYP8B_FsOZMru47rUmrQaXn5yjmp9IYHypqVfXcF5E-WglIPqiyMQZHIvoIw==	\N	\N	New Jersey	2026-10-14 17:03:36.89115+05:30	\N	\N
436	Dp11	gAAAAABqz2iQl2_oLyz9zDQsC-scZsgaw1RsrFZvUI5LkVtQHOxq2vgmV3-AEfz6SVzWrOiqVmnwmjzlIzhTg3CGauSoCRd0fQ==	\N	2000.00	Virginia	2026-10-14 17:03:36.986605+05:30	\N	\N
441	9456	gAAAAABqz2iR5hrPm4FEMpgUbk5P57pIivkFge7jiL063GH_3GEs75imtAQQlx-MHseVL_J3DM9-RmKaWDXk4hZLKmT7FrJXaw==	\N	\N	North Carolina	2026-10-14 17:03:37.082158+05:30	\N	\N
446	Mia198	gAAAAABqz2iRv_xG8ol2mw_SqJah012pyHsA1Nt0z9qm09SUbJeFoOrB_X2O90KAQigdM9CNnuOzZUSKSZmprLrSkn9CvyES6g==	\N	\N	massachsetts	2026-10-14 17:03:37.174323+05:30	\N	\N
209	J5924	gAAAAABqz2RSE2iS5fAXfYijW5ny1_UzCRYrs8bWIWNR2zZXzpJ7gZTHlqTdks6KMHWMjTe6-_OJ1sa2nkw8cO4Bh3zFISFe-Q==	\N	6000.00	LA	2026-10-14 16:45:30.055345+05:30	\N	\N
214	Bdyp14	gAAAAABqz2RSkqwEw4uFDegUI0qgSVaaeHc1W8600HRWhnGujGbkgqyeU_L61DkFV5gKAk74ZQQWo5aDaAPQ41jw1W9djNxImg==	1000.00	1200.00	Dallas	2026-10-14 16:45:30.197832+05:30	\N	\N
219	F533	gAAAAABqz2RSNDSks98NZtiMo-Upq8DLlK20n3duvOfO769BVgbmM6k_hZviJlnDlWFc0cJcR1HGvWooRCOaPal_Sj3ICJryhg==	7500.00	5000.00	Baltimore	2026-10-14 16:45:30.298656+05:30	\N	\N
224	Lv171	gAAAAABqz2RSyMe9Ge6Nr49wK8zUubgwF5beL8iR5MhcarMnmYeeO7l7I4i0TTZ-yW27IXdq7yy_mFy-ckW1odjtOx_S8jo--w==	100000.00	\N	Dallas	2026-10-14 16:45:30.393358+05:30	\N	\N
229	Bgg427	gAAAAABqz2RSkRoCj_F5UXowwi0Uq9s9NCFhEyzpfN05qpaH4BPI6tDxMNA7jWrrse6OACDpvGsxGGH7mbaOPXftVONr_U1dDQ==	100000.00	\N	Houston	2026-10-14 16:45:30.494041+05:30	\N	\N
237	Mg31	gAAAAABqz2iNUcuonUlgm6Bv6mlc5Phv6lC0mdGEEJ2w2E55UdYcWalFInwflyuD7bsSAPun9LH0sqcbrmFSQ96FHbwm3Py8_A==	\N	\N	\N	2026-10-14 17:03:33.005813+05:30	\N	\N
242	Tex2494	gAAAAABqz2iNTIVRnjWXnZluS6HiA8DzZekFAjo_CYTkaDmqou_Q4oh3id1AnTAIu3nAwKCGGjX2QMEY3YW2wam9sw3l2Sgi_A==	2000.00	\N	Houston	2026-10-14 17:03:33.101013+05:30	\N	\N
247	pete26	gAAAAABqz2iNYs0cdBOcd_Ye7LEWJ-cN97Xwp5T_A7ITEv5Ea5MRNLIjvKc_yK2RyxOwYzKDsdVjuOrL5-mnseU7GVq6CTYbgA==	3000.00	5000.00	Houston	2026-10-14 17:03:33.255043+05:30	\N	\N
252	VOYAE13	gAAAAABqz2iNF6FtsIYKY9icwQWpVlNe50j9WIVHV4D6hLmA70XSd_vP6Hq1lb0Z4yykk58RtPpbctp9FRu1Dq1TJQaUYpSRwg==	5000.00	\N	Dallas	2026-10-14 17:03:33.390993+05:30	\N	\N
257	Teab14	gAAAAABqz2iNFlocUER04lqH4oz4L5dPXMV8Q8xOzhT7FAY_huUonRYeP5R5Xx1_wTn1GDBiD20br8yfP_Xq5XZv6M2-gPIJUg==	4000.00	2000.00	Aiea	2026-10-14 17:03:33.488147+05:30	\N	\N
262	Tnt107	gAAAAABqz2iNfcu5yNv1ya36YFEKYKPAmvdHuRbPMy5Jcs1QiW499x_7-8FoxNqwt9j0eOs-miz4JaRUDv163frh9PZC56HarA==	\N	\N	Houston	2026-10-14 17:03:33.584707+05:30	\N	\N
267	Barstool35	gAAAAABqz2iN06HFcPXhAdNwo306QiGD2pjzocNu3kWXioiaHwtt_tTzW586BQ4dYG28SKJGfr8vVo4P0Drc-HNsL90fZSymyQ==	\N	\N	Tampa	2026-10-14 17:03:33.679302+05:30	\N	\N
272	Ch3007	gAAAAABqz2iN44uEXvrzPZzoWbbD59ciUXKNpZWlT0LhUwske5Bd-QbUIhfW7ZL1Ui-3RmUZY1tlRS0j7uHRVAofFnLGtczPUA==	\N	\N	Houston	2026-10-14 17:03:33.774054+05:30	\N	\N
277	Cf218	gAAAAABqz2iNLZjw_3Q6pC_VcVpEY7p3v6qIctVA1h_15jyMd-M8cgmZWmTKrzz9Vs1IUvc1cwEtxAH1GXsw1hnIWQImKB9ItQ==	\N	\N	Miami	2026-10-14 17:03:33.873506+05:30	\N	\N
282	Sle76413	gAAAAABqz2iN-rf2wPnc3PcoD692lRRNmXNB2Gv3Ogj-ufGRBImkMZbleQJa6nBwleLz0Xg-rAybRe-iDbB67YcEGD06tf99SA==	\N	\N	Miami	2026-10-14 17:03:33.96852+05:30	\N	\N
287	Mo8865	gAAAAABqz2iOoH3StFAr0Gyemk923uRT8o_qaoATgngmrMjWA-9YBjoFHdIoNVQdyo7ElYq8KA387IMG9-PG-Slq2b8SWDpN2w==	\N	\N	North Carolina	2026-10-14 17:03:34.065905+05:30	\N	\N
292	W27258	gAAAAABqz2iOM2hXmPnhCPbXqKcoBrVwfQVf-LuuKKfxewXgA7i17r2hzSyuzY3IYdMANAB4J65ydIi0OThzQ57K8o5Js0qWrw==	\N	\N	Massachusetts	2026-10-14 17:03:34.167562+05:30	\N	\N
297	Zpt747	gAAAAABqz2iOgyLAk_IVMCuoH7bGO97FzFBRjc9VQ336XuDXzR_H5a34oIyozGePwYCppMPAqFDMYzNVnMuOum2l8puGbD2ZZQ==	\N	\N	Miami	2026-10-14 17:03:34.264234+05:30	\N	\N
302	Apo101	gAAAAABqz2iOB721SgMXA7r3ZGOtW3KTSvQTTF1sfjmBl2LQeHpMw3WquqwXzBzwEURTfHBFTMeDD-TiMQLp8MqacIwGWLO6SA==	\N	\N	Miami	2026-10-14 17:03:34.362084+05:30	\N	\N
307	9458	gAAAAABqz2iOhAsfG0bNW126FBi4zMx4P3YAxJDz877_1aeBZ2IJdVeWC_sx2WpnMnn1SY2fC5m7aLCIpmtb9KJAuZFHl91v4A==	\N	\N	Miami	2026-10-14 17:03:34.458958+05:30	\N	\N
312	Ct5567	gAAAAABqz2iOPMWe4ZsMl7w2MQj5kzCWbvv3tXMC_CkLnEGesvYZSun7bopT5x0Ala_d6jAlNdqyMNx3vam5cBaVgrNfkKSJ1w==	\N	\N	Miami	2026-10-14 17:03:34.554383+05:30	\N	\N
317	Qq5577	gAAAAABqz2iO2A8c-CHAu-9M-_c62B0EnkjPH-M3HGFUn-MF1m1Q37oLeO8OHMgMfu5lOez4B1-BbBetW5rlNIBKXb87GO8Hfw==	\N	\N	North Carolina	2026-10-14 17:03:34.649167+05:30	\N	\N
322	Mia172	gAAAAABqz2iOTIfuDyxQJD-e8op3TJWJoCvn60VwfAOU-BmB1ni4j_Jv9gAwXTKR_w4Ug_hnLUxv64wYMMy6bq9E4wv28Ro07w==	\N	\N	North Carolina	2026-10-14 17:03:34.74289+05:30	\N	\N
327	Cac1014	gAAAAABqz2iOSJiGPBGksQEWBEhyh9LrDCQ4z4qqwU6tZqH3ZX3oFRDwZqVQ-RMKKp93P3OVVAIX19mHAk6hYtMReVNF4VLDeQ==	\N	\N	Miami	2026-10-14 17:03:34.839859+05:30	\N	No max
332	Dz785	gAAAAABqz2iOZy0ly4V44gzeA8dCXRDYRgzI6NMuQNhGIgFodmUogtqylsiDX7ChAoZWw9gphK1fXARTRZuOysumkrY9k4xYDQ==	\N	\N	North Carolina	2026-10-14 17:03:34.937118+05:30	\N	\N
337	dd0082	gAAAAABqz2iPR3g7yt6LJuTGeKsMFkKUbaamf_9K66FmMJUlrbm_da_3z2OojPSSWBpSbzwlWum0UxBJeUK1yeS7si9hwdCwtg==	\N	\N	Miami	2026-10-14 17:03:35.039127+05:30	\N	\N
342	Zpt853	gAAAAABqz2iPwzYBq77E1uP5I2OtTf0QnCNaRcDY6rfTdDvfDKHxM04o3NXI3--Ser4Kn3tB9DT_twSuvjfXD5d9PXO-k2p1aQ==	\N	\N	Miami	2026-10-14 17:03:35.141617+05:30	\N	\N
347	Bnt510	gAAAAABqz2iPFd0kV9bfD_-ZPeHDP6WeXEIAvXOnl78r45j6d1vt0d1LPJLXnf3z80nd2zlg8RZu2oJNUpAvsRhWAUYq8PbJrg==	\N	\N	Miami	2026-10-14 17:03:35.246832+05:30	\N	\N
352	Bnt405	gAAAAABqz2iPPI4QW2JWlL_sHTA3nguiHcxgFA4LrL6EuHkIMwNdzLdP-a9iJMzt5vpGegrz_f56KWxCRuifSHm6s6IofIshQw==	\N	\N	North Carolina	2026-10-14 17:03:35.353573+05:30	\N	\N
357	Pop900	gAAAAABqz2iPMkCE8VQuTZUejmyn9zpjJxmDXXHvekq-i1BcMYL_BNfP9USbvodaz8KhylHg_nmR4z-dDA67up309U3-gAdUmw==	\N	\N	Miami	2026-10-14 17:03:35.456145+05:30	\N	\N
362	Cnwp308	gAAAAABqz2iPX5gq_4mTp-BK1n2v5JoP6-91MbXJhwWKBpA8uDpOD1idEWfAkY9IG74Fy3wKwVLATnMrvIUhr8EAzbZD4jBTxg==	\N	2000.00	Miami	2026-10-14 17:03:35.560243+05:30	\N	\N
367	JH214	gAAAAABqz2iPGKsk1zKIeSJavthI-ubaZkQNfg7gfDGiQfJ_mcZoThsdmwvsjXYYM-Q1rOO1zKgptpsGqtvKCUoT9b1_6NDq3w==	\N	\N	Miami	2026-10-14 17:03:35.659288+05:30	\N	\N
372	Jh215	gAAAAABqz2iPnPsztuV9U9UKCLrijzQ3nwF7aEBpdsHcu0CoENjeOQy9YwpvkqRnVSuGehgla7AvTHqr7sVCY6pfdoIyDRp_XA==	\N	3000.00	Miami	2026-10-14 17:03:35.752808+05:30	\N	\N
377	Tp500	gAAAAABqz2iPpgmj0_kh_F5J9JEV_NbmE0fFLBfBRM98W9chN-lh5VwIEs6jcxFQHENAULNeIFUYRewRrMNfl8YHy0hMdlAX5w==	\N	20000.00	Miami	2026-10-14 17:03:35.850067+05:30	\N	\N
382	Mia196	gAAAAABqz2iPEWRkDdipAUuqHVAWX0BbUj6ENdEVQUkfogHL_ESOkr-aebdaASqV7IpvwPAIrj1uJAyHu7EHAQ2l6g4ggxeO7w==	\N	\N	Michigan	2026-10-14 17:03:35.948741+05:30	\N	\N
387	Walk130	gAAAAABqz2iQwBMw3JTohEC5RkAtAz48o7fDeKZD9NWvthxaMVddT2MKQtapnsDoEbRm5THet7gWItabtAj-2ymM0eAVSvKcRw==	\N	5000.00	Miami	2026-10-14 17:03:36.048155+05:30	\N	\N
392	Jj1213	gAAAAABqz2iQMPTJepioSrYOGzMVbwxyw0bRW-RzxhK-SCRtL2L4BvKax5bZFGa9eXh_vOPLCRSWyCCdg4_MkCqiecxSAOoF3A==	\N	3000.00	Miami	2026-10-14 17:03:36.144139+05:30	\N	\N
397	Cnwp304	gAAAAABqz2iQ-AcYn66tb5mgLY-Juz3sXlbr3tlZNngcIoVR-PkiR6baI04GQWhw_cwe_h8tSKaYXpevmz-RzjoG1zdptK-d8g==	\N	3000.00	Miami	2026-10-14 17:03:36.239686+05:30	\N	\N
402	Cat6707	gAAAAABqz2iQlj51oHhu8AfVJ0oQsdem-Abl0t-8Vo-aWWjrjoEarEFzY7KNYzuEtQO6d8yjdjgH2tWxDETwYMZNT5ogcCFIBw==	\N	2000.00	North Carolina	2026-10-14 17:03:36.33717+05:30	\N	\N
407	Jhard115	gAAAAABqz2iQX435i3Wa2gOV3BzrS4bv_3zuc5VGI5p__5PurrUibEmbctze-tzP82lstHPNO10S8iVdIxnWKf-RavXGreFuXg==	\N	2000.00	Miami	2026-10-14 17:03:36.429615+05:30	\N	\N
412	Bnt108	gAAAAABqz2iQ68ieDbJ5Ni4zqPcct5y3n9waTv6ewQGj64O67BrdoETAgbNeiJ8DAyds7hkLMF6qtJeF9-qiTXJCKXi1fpxSPg==	\N	3000.00	Virgina	2026-10-14 17:03:36.528454+05:30	\N	\N
417	Apo104	gAAAAABqz2iQ-CLoKEl4aKOxAplQ5hwmMYc35vPseMiDjZezDp0pAZK4-rzE1PpP8VU-30V0k2z-e_s3_18McLIU1V3yWK3Ylw==	\N	\N	\N	2026-10-14 17:03:36.62572+05:30	\N	\N
422	Jkl024	gAAAAABqz2iQkUuAqR3j1cMRruMvBS_JbZp-dOlXjTaHuK9l0m-k8yRbdqIGpGudBEm_1cyLFnWQZEi-hxCPJVFIZfBAjFEQuA==	\N	\N	\N	2026-10-14 17:03:36.720734+05:30	\N	\N
427	Cam889	gAAAAABqz2iQY1FbAPeF6OsvKIf-zB3SITwvWlx9Cx76pWQCmQVnUekYb4GeLC3OuHLzDNWmsRI9VXCXAhbgMQSqnBZe1PmXPw==	\N	\N	North Carolina	2026-10-14 17:03:36.815739+05:30	\N	\N
432	St936	gAAAAABqz2iQqpJi3CVfAJNH4gDTPBm9QAk0tXI5zwlmr-No0gDoSvg5J2Hb_lOiV5meFRNEVFUMb9JKsPcRkshh00w6KcVzZQ==	\N	\N	Dallas	2026-10-14 17:03:36.910905+05:30	\N	\N
437	Jh155	gAAAAABqz2iRwfezOSrdmQBtFUcD9FeCgKmhhG5gAPB9W7WU46ZeVfoH4wSLVeqzpkpg6KtHGqeeBK6AkWYOfs-fhSLH-n-JlA==	\N	\N	Miami	2026-10-14 17:03:37.007574+05:30	\N	\N
442	L607	gAAAAABqz2iRTMG1mNPvcwfHAokrwBodwQZ0M880qZI-fS-pnQs6za5k7RA7NWOTrCzOW0O3YnDpfa-_XpsuDNQg_4F0p79Chw==	\N	\N	Miami	2026-10-14 17:03:37.100846+05:30	\N	\N
447	Mia184	gAAAAABqz2iRilPoB8DbXObD0q5UyvD8aK2xdSin6kXbYqg5wxL8KGd_DA7CFq_mQtJlCFs7ybt-_iAC4P38AamkxrnFVfa-5g==	\N	\N	Washington	2026-10-14 17:03:37.193027+05:30	\N	\N
439	Ag2025	gAAAAABqz2iRY61RPu4FKCD2taW6JAOBlPO1bkiVSG2p0ivAor6R-8iaeyf5VS3l9ns5yKMQroEStgNL_Sr5eeYzT7YhVuZeiA==	\N	\N	NYC	2026-10-14 17:03:37.044928+05:30	\N	\N
444	Ad9955	gAAAAABqz2iRVQsYF-tAnTtoeGCWvIouGupZzodVjhX10s19mGU04dH_QcvMSiJHGws8A0KI8Fzz_m3BkF3yioNA70FpIG6fHQ==	\N	\N	Chicago	2026-10-14 17:03:37.137236+05:30	\N	\N
449	Trbl374	gAAAAABqz2iRhZCrPGXL1BRWTyzvOcwVUatbxrUP5MP28O8YO8liPhryygffIAxOWX3VRsrLlqj6f9upZNJo8nSHvz92rUDdxw==	\N	2000.00	Tampa	2026-10-14 17:03:37.231875+05:30	\N	\N
454	Mia182	gAAAAABqz2iR9y3rLGK1Jk6FCQKgSyW6Aoo3c9AWEVvmHgURpBcPA_xbaYe12mH2t0kvImqC5T-DZSZH1eQQKnKSeZndFQel_A==	\N	\N	NYC	2026-10-14 17:03:37.325229+05:30	\N	\N
459	Vu5522	gAAAAABqz2iRF8oqz3FFT7GLNMkpBLjOU6FJ0BCNpdddO--RIlP13KVVGZaAm1mUNL1BgiH4WSELNQnqLzoa0CDIz8c253bTyw==	\N	\N	Washington	2026-10-14 17:03:37.422048+05:30	\N	\N
464	Tb352	gAAAAABqz2iReA7fGgIAin05bMZNi32meK_lRRcrgspQGRrFWP3E_mwuqES4vK3nrUnqjNr1A9KKiuESDPBBfYbS3htg4nZmbw==	\N	\N	Miami	2026-10-14 17:03:37.517093+05:30	\N	\N
469	Ppe120	gAAAAABqz2iRP2wXrsXnhChhL_XmHI5Hf9KxTyHveSfl7oVqPaKYtXAe8x_i0yHhTjl0fkZ--7674a6C-7hUP_DltzJ1hBmjhA==	\N	5000.00	Miami	2026-10-14 17:03:37.612913+05:30	\N	\N
474	Acctcc1	gAAAAABqz2iR-uYcQ_J4CdWEtlAQWdN4btlBERUq1ZWmeAzzeOuGQgV0ltCwnEvCS-yTY8_41mllfP3HKvDK4x6M6CwlHh7PEg==	\N	\N	LA	2026-10-14 17:03:37.706545+05:30	\N	\N
479	W27273	gAAAAABqz2iR19S8_pa7MCesGf867HarSLlvgGW41gQ9axyCT7BqCgdZ5t7Uahf8Dh4XgFhoeVZOQV8VX_gFvmW7pZPxpSMijQ==	\N	\N	\N	2026-10-14 17:03:37.804475+05:30	\N	\N
484	Bnt402	gAAAAABqz2iRcA5v0i80Sq3SxxKWLdMTDLQgAYm1XkaTQUPU2EsrHCmRsITtpS9tp573imAhS6HqYHZ-YmDevTPEzpCRgzD7oA==	\N	\N	Miami	2026-10-14 17:03:37.899588+05:30	\N	\N
489	W89348	gAAAAABqz2iS4-vlHBKaPj5lHNbLcmq3F4jr0qOK6iO47Y-Wmaume53Xx5PKU6qkluAr1FUQpxIRusVo_y8zpZa-vNrpiKnoLg==	\N	2000.00	Minnesota	2026-10-14 17:03:38.037994+05:30	\N	\N
494	Z10609	gAAAAABqz2iSpr0xTkD4yFNE7LjILANycCyPOyB0w4on0D8d8g2fRnPxesTMOJhXGCfoBJgyto28qSbI4Kyrb0ljXK1NRk9CKQ==	\N	\N	Costa Rica	2026-10-14 17:03:38.140999+05:30	\N	\N
499	Boc524	gAAAAABqz2iSiFOcjHY3hg9TnbWZxgu7MSvKJDe8uxE0dgqLnby07xRVcYG0eZVagcoZru0l6_QKB_-E9dcmLWcQzhDT0pGL9g==	\N	\N	North Carolina	2026-10-14 17:03:38.237771+05:30	\N	\N
504	VL13	gAAAAABqz2iSvPv_ElsBKwQIFvNqSnjD9SAUASmMKZMS6-GHSpNhOSkb6S3x1_BgdJ4cjkijMjfU1Y2pC5iPzEij5XajkEWeBw==	\N	\N	LA	2026-10-14 17:03:38.335822+05:30	\N	\N
509	Rod23	gAAAAABqz2iSthoTDxqchRoV4n0R3migyLDMBLz6WOlN4_zfi4mXeMH4bwt5H4dPA_g4wNbUXYZdgF-fl6QF3uRd3PPuU9kdnw==	\N	\N	Miami	2026-10-14 17:03:38.433444+05:30	\N	\N
514	Rc539	gAAAAABqz2iSoQUgquxLKAKYuzjZ4R5KEDhPEk4sh8FbeYD8NELdXr-FFy-QPtPl-Wv8ANVKWlUv5SGsb_EqpAkOMP4v7VUAhQ==	\N	\N	North Carolina	2026-10-14 17:03:38.531121+05:30	\N	\N
519	Fm1564	gAAAAABqz2iSP5mCieVlg2eYoI9pJL6ZaJS-_6CBINtreUp2-VC5SfjN2PcGVet23XSzwqtTWCTdEOfusNJUBiJmedwbrvHtcQ==	\N	\N	Miami	2026-10-14 17:03:38.657076+05:30	\N	\N
524	A7938	gAAAAABqz2iS7WPXXCk8wIamXDmY_AMHZIKWuobJLb-QwXJhvUMjzIC74YDSAnfFmOBNX8xJv8XbvLSincT8g90y65ExrbagWg==	\N	\N	Chicago	2026-10-14 17:03:38.753197+05:30	\N	\N
529	Elc1161	gAAAAABqz2iSpx40WhDinDSsaix9IQFlSzmmXlGo2luXk2z8qqrTdduyz5hcI3GMF4q398F2d1q8nE-0AiE3c26VwJIi0U7pXA==	\N	\N	GEORGIA	2026-10-14 17:03:38.854119+05:30	\N	\N
534	Meridith10	gAAAAABqz2iSTdbDGVWxlBYg1zDAMK1r07CX_9mdEerw-0JHWMtmhcNrsU_dHOJh_RUm23d3BGbyTQi0tLrwsiMOWLek22lO1A==	\N	\N	LA	2026-10-14 17:03:38.953207+05:30	\N	\N
539	W27256	gAAAAABqz2iTTeI6O8TautkZfOgiZGbl3eR1syzDnvJartuRZsFgCJhvmN4W0REAn9BjtOEZuQMHmIjaaUkzjZCP4gcwOL8UXA==	\N	\N	Miami	2026-10-14 17:03:39.049173+05:30	\N	\N
544	Alan224	gAAAAABqz2iTbf38G6JBiaxYtMFCyekt4Z1z4CaxSGi-MI_Z2lbvXoMk2wW9nBqbER_3XxiPQf1t8jyD9g5UWsXWEuJ2sK5r-A==	\N	\N	Dallas	2026-10-14 17:03:39.144702+05:30	\N	\N
549	Ais507	gAAAAABqz2iTU43L329sZHV4YoiYpcKNWfy4EADpAanQdPZ3ysKM1ow8VOOKoyi_Q2TL5jB-p-iA9TJlR97h2Jji1JZ04g9HzA==	\N	\N	MIAMI	2026-10-14 17:03:39.251573+05:30	\N	\N
554	Dawg44	gAAAAABqz2iTkXB4JnwL9IdOWT1lwvW0nmyZcfK71UTkQ0kjEy6Iv59dL4enP1m_hPpNn_6OCkXn3kt94Q-dm0ITthVIfJAhAA==	5000.00	\N	\N	2026-10-14 17:03:39.346219+05:30	\N	\N
559	Co18	gAAAAABqz2iTCrZ7czfKxh-yX_ZK48-y7ofzoIRIWVQ5JvzHERyQRnkofFtioNcrfAb8clYEZknbqvvIv_3XLagvKGSq7CwxIA==	\N	\N	\N	2026-10-14 17:03:39.443952+05:30	\N	\N
564	WG213	gAAAAABqz2iTbtQhttZ8Fkn6lCIDXzHi9BrVTZZBfIBY3lEkHA9EMCX0XTrX5rbepRXsr9xKefvSQhuHYl0oOL8IxestGnUv6w==	5000.00	\N	Omaha	2026-10-14 17:03:39.538693+05:30	\N	\N
440	Pm8888	gAAAAABqz2iRkjs3nKWQgje1fUyoQZKwQd6dTFNj_KMBv5WIKWHHe95UJjPpH3mHzVqAIPUht6O0BI8M4XxY1-Kf8QDOpJhx8w==	\N	\N	Virginia	2026-10-14 17:03:37.063487+05:30	\N	\N
445	Mia206	gAAAAABqz2iRfG3PzhbgLvmBM3sg-qEPMOwgVJMYL1DjRHKlX2Xe_rqefR2arA9pieYyBJbHyCF9iX1ksMr3NEd7lInQzUABTQ==	\N	\N	Dallas	2026-10-14 17:03:37.155974+05:30	\N	\N
450	Trbl379	gAAAAABqz2iRVBflbLS1KPeBLiRDUGA3nFRC3TqCUgqdZ6lZrGtIlblPxw74k7pgnOzMsWw4Wxka9yduyGBs5zF5PR1Er4JwkQ==	\N	\N	Virginia	2026-10-14 17:03:37.251089+05:30	\N	\N
455	Mia173	gAAAAABqz2iREQMcRTDI4q3sO5FWvXDhpirTB9X03eMoQGIImzMWbwOudPg75ZGAFqFWxR6TOYcUFvy3vaewHEsAoU0KDu6ryg==	\N	2000.00	Atlanta	2026-10-14 17:03:37.34396+05:30	\N	\N
460	Mia151	gAAAAABqz2iR_075C-iB6kpJARs6f-0z5c450M9ATIq3bp2SrbRTfaB1Zsose_ErYuch6ADQopda8Oc-Fns0MMUDXubSwGLd5w==	\N	\N	Alabama	2026-10-14 17:03:37.441329+05:30	\N	\N
465	Tb327	gAAAAABqz2iRPHevub9AK6a7R2EfdL4LEn22nt2AoMfllnWXiBJ6U1xhvTrespd9di3XbZIbimm2p-lfmx_MI2_qIJrGIfD05w==	\N	\N	North Carolina	2026-10-14 17:03:37.536011+05:30	\N	\N
470	Jh217	gAAAAABqz2iRZTvVBm7fZLHCLPAUy3DgszCAo0-lAfXNbOh1Polf4xV9Tlh78wLnoUvS5LBUD7hRJhN-Gm0oXkYS-r3QF9D_AQ==	\N	2000.00	Miami	2026-10-14 17:03:37.631442+05:30	\N	\N
475	Fsu136	gAAAAABqz2iRc3UOgxAIZMKgD78iB5Jiirk2I20p0BIxxQNYB0wEhXcoOky6gmlWXy3rIr36dYZJbjHUgvuFK-9GXYNL9D9T9A==	\N	\N	Miami	2026-10-14 17:03:37.726555+05:30	\N	\N
480	Zpt840	gAAAAABqz2iR_Ei4wp_pIf9r4Shk46nrEdcRVtdo8H7viCv6gcSC1GKHMomjC4H4t9XyHIAXBwozfz6KKmMsLOIDdU4wCrTmhw==	\N	\N	\N	2026-10-14 17:03:37.824407+05:30	\N	\N
485	Bnt504	gAAAAABqz2iRP549D6deY9qyM0_Cujf90hA61w5wTcr-N7eEgfJxoHEC6L6XKokoyiH7gd2ihdbqXH0HX9DJvku5rLZQhwj9jA==	\N	\N	Miami	2026-10-14 17:03:37.947872+05:30	\N	\N
490	W89358	gAAAAABqz2iSYMO74xwenHJbDp1bio1APGRxbLJV0BtmEOAKodGQYWkwOh-zrbpRJNCKtQ_8LWCOhUYjZUCCt9TOo5EQ7ZLHrQ==	\N	\N	Miami	2026-10-14 17:03:38.058314+05:30	\N	\N
495	Blue0114	gAAAAABqz2iS8P1tYtW1KQfc3YSqVwIvV5QF1svTyH0xQtB5bDX8T7lf51e_1D7Pwbe7xGoi0-fCIlrdy2opJvmBR3GuCluFfA==	\N	\N	Miami	2026-10-14 17:03:38.16118+05:30	\N	\N
500	Kyle224	gAAAAABqz2iSSyLsZoHpMpcSraQ5YFAvDWJOADTDS4R-0haHNyS5IusGdJOHrOw2e2Uz4ZhxRzf87hVcHvA73OQFMkaFKldhDA==	\N	\N	Dallas	2026-10-14 17:03:38.257183+05:30	\N	\N
505	Xjg4544	gAAAAABqz2iS24RWDOEnbjS756viEOaxfJtzUHZ9Jfr0_OFco2f5eO9lf0sxXv5d2ctw9cMxeUPXHLbEn3pA4pC8pJXvBLTMkg==	\N	\N	NYC	2026-10-14 17:03:38.355473+05:30	\N	\N
510	Lukee123	gAAAAABqz2iSz6-WaxkvJF3Sy7UmFwllrOELW6bnfEiMwdpoWGRguigmikDKytB3rHa09actB1JQZFNNJav3BWV1yB9t9VnNXQ==	\N	\N	\N	2026-10-14 17:03:38.452785+05:30	\N	\N
515	Tn331	gAAAAABqz2iSvRzCQD4W8_uI_-c-n976KCRQsCgDI-qv3Bp-J75IHyjxtXO5vNixRPO8ilVINXtdOB4id381hHzbfbZ_p3jKgw==	\N	\N	North Carolina	2026-10-14 17:03:38.550143+05:30	\N	\N
520	Qqq113	gAAAAABqz2iSxsw9vnJ1vz9OFrW5gxTnFq1oNyDHR3yYspurwW7UWL3ffTaBNjvOZUtLfuEjePPFZ7knUolcGxvP3ArLUuew2g==	\N	\N	Miami	2026-10-14 17:03:38.676883+05:30	\N	\N
525	Snak1	gAAAAABqz2iS-aa0Kg1TVvrqajrrR5zI93GQ6I5kPZuWOHCXROg46xzowCuPWHSedx2q_6zNYnTLrnUD1zKkIr2oLqJ385n6TA==	\N	\N	North Carolina	2026-10-14 17:03:38.775296+05:30	\N	\N
530	Nw10047	gAAAAABqz2iSDQhz3_M25GqTWKAVefIoYHo0QziXr6i36sTRqMUYbHsRcHtlPzHCK5cGL-1W4K06KIw7PnFA69SqUwngz9YDtA==	\N	\N	Atl	2026-10-14 17:03:38.874696+05:30	\N	\N
535	Mf437262	gAAAAABqz2iS__TG8kiaNCdNV1V0wYKtctUoTwUUqMmLG5LVgcveG6Afq2GQ0MtsG_pYOiZ9RH5ijjt77qVdzoKTtr3vLmdeTg==	\N	\N	\N	2026-10-14 17:03:38.971288+05:30	\N	\N
540	Apo105	gAAAAABqz2iT-rnZGACqEDYQgZBUe8Yj9LsRQLJhDFPrFTWfDQIxBkkObfgJ10qVrlvdtuZZQSzjenluvL73TV1BaLNWSozUpg==	\N	\N	North Carolina	2026-10-14 17:03:39.068025+05:30	\N	\N
545	dd0062	gAAAAABqz2iTRwyMqbTaNY5ASEsveQKfJFbJciPccHKjUszL8VR52oQLkxtaFjetbtrLBZNH3EMNs1HNxuGPmINvj5uFJ_MA2A==	\N	\N	Michigan	2026-10-14 17:03:39.165925+05:30	\N	\N
550	Kaf219	gAAAAABqz2iTDNENif1r9LG0d4rdgsmF1w5bm18ivEL0JEaBIa05hfQ0fU2wcaFBhGJIZzV2ni9oUP-l6CiGOut0nscTRGwauQ==	\N	\N	Virginia	2026-10-14 17:03:39.272186+05:30	\N	\N
555	W22885	gAAAAABqz2iTQLx4w_Kd1lppr-3Ftb4ak8uH83eXQEqpUYJd81L1SULFHFPfvN4k9S9jirGi7fOL01KlN6CJhqSu3WDG3C0KBA==	20000.00	25000.00	Boston	2026-10-14 17:03:39.364707+05:30	\N	\N
560	Kc2526	gAAAAABqz2iToLP7CdzZ-ky7Y1DgDK-N7QwsFrUstZahGMok5QNsJILu3CuBqHvOCk046WD9j5FhfA_usdh72pi_jwGPaoQ97w==	1000.00	1000.00	Omaha	2026-10-14 17:03:39.459415+05:30	\N	\N
443	ML5984	gAAAAABqz2iRfvh6RG7Jcux-TNCbg6Obx6A1c0hRFRyZ0i8mxx9NcxpgJx-cUMuRENvw4MWK_zKv6uTAuMDbv4MwbQ4pzd9jrg==	\N	\N	Virgina	2026-10-14 17:03:37.119457+05:30	\N	\N
448	Trbl375	gAAAAABqz2iRQu69rXaXf703BrKJVGM8MNHUmZq0-_BBAHSysziJrNVizFNeFD4jJFy-SPPdZUXdikKJH1GWYHTEIt9Vayop6w==	\N	\N	North Carolina	2026-10-14 17:03:37.211979+05:30	\N	\N
453	Mia197	gAAAAABqz2iRNp2U8gUKWMXVLSgEM-PkqCabYRD_2YzkkUuaUI1Ga9kkpM_cxacKkCx62yRDPrM6xLIfsxykEDotCEw8gof4zg==	\N	\N	Chicago	2026-10-14 17:03:37.306179+05:30	\N	\N
458	Yy115	gAAAAABqz2iRZ8F63JWR1w_v3A3VVvuxDB7cTWXg2pZ7R9MWMvEVmtwDrMpUVn64TxbK29NtHvYB-k8zD0mMMfQc143kL61gog==	\N	\N	North Carolina	2026-10-14 17:03:37.40414+05:30	\N	\N
463	Tb322	gAAAAABqz2iR_4gfXRKxh--OMmw6w_SHTGdsYel5fn64kPqOClGCIiXf6Bs5jz9P4OodbQLTlXsYHcTbwkQvLcOmcnpPfQ_0rw==	\N	5000.00	Tampa	2026-10-14 17:03:37.499175+05:30	\N	\N
468	Ga107	gAAAAABqz2iRSnSqSG9cmd6HBQTEP_o7bWuvdHH1WcsAH9CNsg8HG9OuqVrTvPSXc6Cl2fv7SQqNWn3-erlAAA9tNwFwV8XeSQ==	\N	5000.00	Tampa	2026-10-14 17:03:37.593432+05:30	\N	\N
473	Jr269	gAAAAABqz2iR3rGI_uRORf2s_t_qqbz1y5-zqXypia5BUURev9ajsrFs98ZevFQuM_nnrv4l_1PVpgJn1XbttEQdipkML-MqUw==	\N	2000.00	Miami	2026-10-14 17:03:37.686867+05:30	\N	\N
478	Willh600	gAAAAABqz2iRjBVcJ-VFpEIvIFYI8VZR5cp7IJL_TSN_erKR6URwGZNEceXiNRjSh9-i-bFjUJ4fhb7Wwid7BZUdqsEoSdpoFw==	\N	\N	\N	2026-10-14 17:03:37.78559+05:30	\N	\N
483	Bnt509	gAAAAABqz2iRATebJvawsCLV0QHOjwyQAaOPa30_9Pp9pwkhBBclzrOTux0vIXUXg7EaPslBXJ1dgXZgIUZNtnnjFFUrqnIG_w==	\N	\N	NYC	2026-10-14 17:03:37.880659+05:30	\N	\N
488	Bnt514	gAAAAABqz2iSceD_vDJ6jt6-RWC-KtI_ymt0-jZyOmNJxhd00Fd55xWhekNocv3HnzdeF6dDwfpG8sQenfmRNOlOKR9s9GoOFQ==	\N	\N	Georgia	2026-10-14 17:03:38.018666+05:30	\N	\N
493	Fm1564	gAAAAABqz2iSKEqeW5KO_iebo9CyQSbLctTQ9lz5T0p1a9YG-lvQ5I4GqECD-_QGbXspsxU-5mN7rHE7PtvxmICbRvIZchMijA==	\N	\N	\N	2026-10-14 17:03:38.121847+05:30	\N	\N
498	Roa3	gAAAAABqz2iSQwPtKbczHeIjeSgkvb4p8i-qbVCZtMARFBm1D_uWq4iGDXsCFbyK-_xaPs7AOqcmK0Guhiey9rrlU7Wav4Ld9w==	\N	\N	Dallas	2026-10-14 17:03:38.220985+05:30	\N	\N
503	Cd444	gAAAAABqz2iSf_oyNrWUP-u8zNYktg8FjiTL9KBreEkiO9zEzN1PlGMV88Sa4z3ovmg07gFN5I3D1OsCwGz2NH5ZpHLtn-EzWQ==	\N	\N	North Carolina	2026-10-14 17:03:38.316005+05:30	\N	\N
508	Xjg4542	gAAAAABqz2iSknvuP9OMgkTqIFQzeHrGAHR4lg6BBtnl8lGBVrGi4JFkTR3ERpqIxGp4pdrzechea-DBfrQlHYlzTxaltdw4TQ==	\N	\N	Miami	2026-10-14 17:03:38.412856+05:30	\N	\N
513	Giov244	gAAAAABqz2iSIaGM9AQq7MnpMAyovYYpkZSIu_AM3bcWj6GonSfr33efEjcX5Wb_vFaLo_Rua2E__x31SovGcPmTEG9gBl4uiA==	\N	\N	\N	2026-10-14 17:03:38.51208+05:30	\N	\N
518	Gx403	gAAAAABqz2iSaAIr_fhHF5h_08uQgXt2AUUWY5VXkPad2-kCYHXAYASOFgYB5lOCFjosfZ4hJFG_LbywsIv-raVqtsbFgYtIYA==	\N	\N	Virgina	2026-10-14 17:03:38.635071+05:30	\N	\N
523	Pan956	gAAAAABqz2iSFdq0Em1bj1kSALBsWLrOt09QMaSSXWDxV3xUGq51g4HoPOrbrCEP_f3252c8UN1hCf4XJc8JHcLIJuVPJ_et2Q==	\N	\N	Chicago	2026-10-14 17:03:38.734435+05:30	\N	\N
528	Rj5838	gAAAAABqz2iSWaZIdk49_Ibc-Cfr1YgCNKFBqKBo5Mm1jPweYWJqcGo-czJ8KQK2LUUAI5ggbYgInifYsH1jjFo-2p7v-33org==	\N	\N	Miami	2026-10-14 17:03:38.835353+05:30	\N	\N
533	Bbog25	gAAAAABqz2iSefpLcfzVvKM3hRAVnN0xLmCBEns4czvzXvPpUIZtFT6dlsZhXFTyCL9Mz7ONQAgjYD18Fv5EaMbhlU-q3TO-pw==	\N	\N	Chicago	2026-10-14 17:03:38.931913+05:30	\N	\N
538	W27259	gAAAAABqz2iTUCOvsMTZubQkKovq6fbhEg53Y27FEFewwW2oIhJ1Kq_aaYJ-uTNcrepHqPrfPBkNNoSQj9EjYBwvRfPCTOF_gg==	\N	\N	Boston	2026-10-14 17:03:39.029341+05:30	\N	\N
543	S2688	gAAAAABqz2iT_5Z4XKcAC3kufeFvltaynKR8m3aBGCh636dLPROq6HiQSBGY8tJFIcmgZbml1_mu0Z-rYjdjOxWtdxQCszVUUw==	\N	\N	LA	2026-10-14 17:03:39.124971+05:30	\N	\N
548	Jb133	gAAAAABqz2iT9BzbHQd8AzhKtAoag3bkkO8gQITtUdQXY833bZUk9_KdsQwMi5CtjavJ4fkIydjzSvx9CEZtmpVSmj1F6_1wEQ==	\N	\N	Athens	2026-10-14 17:03:39.23358+05:30	\N	\N
553	Dawg202	gAAAAABqz2iT3hCas-VTPnFmYUnJ9izksaLzGvKkxM03gwIyNu7i0ZPs5DdFAt9A1JmykSW2-4FJUOWrPRr-4Jhe774gLqjSXg==	\N	\N	\N	2026-10-14 17:03:39.326703+05:30	\N	\N
558	Ml7	gAAAAABqz2iTIgrKxDWejH1nTZpytgUlf85SV3fk8e2-Sz6_rpOVW402KVW0H3ffzNMMh5PsUQArOvkG87lfwZoMHq-GBNDY_Q==	2000.00	2000.00	Orlando	2026-10-14 17:03:39.426373+05:30	\N	\N
563	JB351	gAAAAABqz2iTpjZUVXCjDps7ayrhToA0yf5G6KjdfVjng7-XFV7Y1BRkcDZP7DPsuFJz_3mJBPHs2B0FJjRN1ozQyl6uO9juUQ==	15000.00	3000.00	Omaha	2026-10-14 17:03:39.519558+05:30	\N	\N
451	Trbl373	gAAAAABqz2iRN9xIsGwvgerqLi23YYvwaGWm2fVW2DrVGqK1225YVeLwNf204kWs8SO0hdudwY5GtEtpqWQd4LwXQF1EkC15Iw==	\N	\N	Miami	2026-10-14 17:03:37.268968+05:30	\N	\N
456	Jj000	gAAAAABqz2iRyCSPsNopymasnEINWNU1JecQzTavCvhtC2JEG3YJYwYnhjSqe5kQI-i9cR40_PwK3aJ_ApxLbMEHWU-CcNAbQg==	\N	\N	NYC	2026-10-14 17:03:37.365573+05:30	\N	\N
461	Sg6161	gAAAAABqz2iRlNn0isF5OLXhYgCoJLwimHQ_YWdG8MR7r13aCmUW3P-2JRLhwYpaBpjQBSHHYoipCsQI8bZqFgHummHGsLWeOA==	\N	\N	North Carolina	2026-10-14 17:03:37.461604+05:30	\N	\N
466	Tb358	gAAAAABqz2iRi93OfO4MTnXvtkkjeMarssVsjKRe679UFHlqwALh_zbmVXUG_ePKYcEGxdczh3uJJLUnS1Yd_Wpbaqnxcs8i4g==	\N	\N	North Carolina	2026-10-14 17:03:37.553781+05:30	\N	\N
471	Tc8304	gAAAAABqz2iRDpG-Bn0QWLO8yPloeFHXq-s-E3FQIUcOmm2fn4PnJu23G1TU136G0fK4rDlP9iyIyhjjRNdBFHDwn8LHOMcKuw==	\N	3000.00	Minnesota	2026-10-14 17:03:37.650134+05:30	\N	\N
476	Bobby125	gAAAAABqz2iRMv2PHTb0O8IS9oqxyWULSPTmER41IIdgWJtQpDeLBN1QSSZt01iQxj0HVRXjWOxlEZ2swHgcNBufh3ScyUE1WQ==	\N	2000.00	Miami	2026-10-14 17:03:37.745361+05:30	\N	\N
481	Zpt854	gAAAAABqz2iRCzNMPhD2yMBuI6Oe2UcaFBvwfmLLVrb7RIzLl7Mfc_kF9N_SpQ2_tODOx5Vtx_MIc6QyL_iMx0_f0YYlj1cTRA==	\N	\N	Minnesota	2026-10-14 17:03:37.843067+05:30	\N	\N
486	Bnt508	gAAAAABqz2iRfY15YxRAHgcalcoby4C0KNq2FvriewqoENsATAMBRrlIlAOBxVRzoptTeNmzlddJTBKZokrbmM3Kq4z2X0Tj9g==	\N	\N	Miami	2026-10-14 17:03:37.975627+05:30	\N	\N
491	W89347	gAAAAABqz2iS_uJwLyIjen0M771h6xzdNoMqE3q8RljaQVEIipVvj-QrdBLpc1pn4vS-aqYlyFp-IfL3vBUionwej7uUlQMMtQ==	\N	\N	Minnesota	2026-10-14 17:03:38.0817+05:30	\N	\N
496	13-730	gAAAAABqz2iSAGhtWCFI99UPDolJAw5Pl7a31M5qJpfUYGRSU9Xl4z91mwLxLAyPZq-bo0UcIgkufblhrEPU_qhbTxK4U3Pw2w==	\N	\N	Dalls	2026-10-14 17:03:38.182961+05:30	\N	\N
501	Karlc	gAAAAABqz2iSE6sO_y2Y70zvWo5pqKQ9HQPR3s_heUmi5fAVGWuraObPO6U7t-idkWO2XWcT8PzVNCPiQBp1Ao39oAgIvcZK2g==	\N	\N	Alabama	2026-10-14 17:03:38.275512+05:30	\N	\N
506	Xjg4540	gAAAAABqz2iSWBGB_xOTnZDRAc3GnTGxSkrJDuTelKvVbnZiea-LVHibkTC0WqEo-FUkWfh_sxA_TrD6bFSycOuvssaqN9Bz-Q==	\N	\N	Virginia	2026-10-14 17:03:38.374833+05:30	\N	\N
511	J742	gAAAAABqz2iSOtXvQQxexe5-jmf3w4mr2M5G-1GcZiiVpDcj6Qa6HfborE3tVHbJn-eXNurK_RM2mh4mTQQlv0nI5ZTNPmL-Qg==	\N	\N	Canada	2026-10-14 17:03:38.471279+05:30	\N	\N
516	Tn329	gAAAAABqz2iST4auEiT1DrPve8BeZGWipilPIafEfdnYMAVS0Jkdu_wMIVrS2Ww5ZqOsQuFkKUDTibKQZWue3kG_o79PComYfg==	\N	\N	\N	2026-10-14 17:03:38.568276+05:30	\N	\N
521	Jt1689	gAAAAABqz2iSPY8hZkLO74Gszs1AVfKLUWYMQnabuH5q7g0HZi6Cx-_dROpu-CF_ggc7a_x89ksDFPlkWdgIf07FcXytIVQf_g==	\N	\N	Miami	2026-10-14 17:03:38.696961+05:30	\N	\N
526	Az0106	gAAAAABqz2iSTOTgehl7eEokDtzdQ5dK9GsSzuZFgRtoJt08Ig2AGZYczXxrZFABSHdU_TJJ42EoxYMzJJuVB2l1pWyRDK-B0w==	\N	\N	LA	2026-10-14 17:03:38.795218+05:30	\N	\N
531	Elc1132	gAAAAABqz2iS_T07QWh1mRXGWRcomMoS1R3IVl5ojvbonf7Wdd37CbYJOfDMgQOarts0CD5WkTYIuP-lArp6POGvNBE0CcEoTg==	\N	\N	Georgia	2026-10-14 17:03:38.893956+05:30	\N	\N
536	Se324	gAAAAABqz2iSEe_OudAE6PGxfaCcJ3scgrRiPqkTR9q0rXzxRYJi9KJ8W3SoiOPhNXb-fYpn_6sKoG6J-sLJCGtGpnYnXhJskQ==	\N	\N	Dallas	2026-10-14 17:03:38.989385+05:30	\N	\N
541	320	gAAAAABqz2iTW-Jzd5UFQUZ6CWDnNNTK7ejwx8RaF28Kqa3XZMtgOE9lZDbeyfAce0CwrIgzRLoCecss5qoVIrqoqYQZxKkfNA==	\N	\N	Massachusetts	2026-10-14 17:03:39.086932+05:30	\N	\N
546	Lca2601	gAAAAABqz2iTFZC50WEIogCGTdPcjem8stG6xn7PIux4HAp2AwHVIPQRlh9qHtF6d7jn_GDqDM7-R-PqT3aClwdsVSGy4rY8fw==	\N	\N	Dallas	2026-10-14 17:03:39.195759+05:30	\N	\N
551	Snl59106	gAAAAABqz2iTiMR1NyZARnlZGSZJBOC2VqOWxsOdCQlM6DeaELJU4UgqTxevv0c8MScmKSeC6EqL1letufjlNQf0lMlsd5E0YA==	\N	\N	Georgia	2026-10-14 17:03:39.29139+05:30	\N	\N
556	W22662	gAAAAABqz2iT-tfaNYI749DwDK_bffQajVBciszkPR248WwJEGDFrdwdkgIC3jqQ1o8SxgrADwh7N5V-1Lwhg34Npdm7fGzayA==	20000.00	20000.00	Boston	2026-10-14 17:03:39.386199+05:30	\N	\N
561	Db613	gAAAAABqz2iTmNpvEMgFCxuL4Tqz-s2rQhV1Tuc-Tx_EnNGio7OG7uSTm3a_xVtuTgTUSgJcvV6BMvd6r2c3lY7axAkBd2La3A==	750.00	\N	Omaha	2026-10-14 17:03:39.479077+05:30	\N	\N
452	Mia175	gAAAAABqz2iR3QF4oGoTaUlyAg9LMjR58-CLmECvBqoOkR1Wplnt6pA2iErPmz5DsxOBOmMFq7tVrTXW-G1MmeAKtrnTn4fkdg==	\N	\N	Miami	2026-10-14 17:03:37.287966+05:30	\N	\N
457	Sj8888	gAAAAABqz2iRSEaREPuBSTZTrtRjhhzajiWdrEPNbGLPt0oJqjwMF9AffC4co1LeC7nHNF9MT6QEISDGULsEoVOe1b3OEpRRrA==	\N	\N	Atlanta	2026-10-14 17:03:37.383873+05:30	\N	\N
462	Tb362	gAAAAABqz2iRzuFQlTK4UQDH-PP8XCzO97O_8J7CmIqSpwv7PpS2TTS_qgcCAl8-_nLNa1l2UPYhG-GRyye2iqlHnzVZa_2lOQ==	\N	\N	Miami	2026-10-14 17:03:37.480491+05:30	\N	\N
467	Tb384	gAAAAABqz2iRfKdDvarB5yDYZz62Ut8dMis44Ik0XtbdCbdZQi_nT3bBRMnTCwSV4p-WXOCdyj9NKj16Pi8ZWlUd1-HZwYPmCQ==	\N	\N	Washington DC	2026-10-14 17:03:37.57347+05:30	\N	\N
472	Jh177	gAAAAABqz2iR35Z6Bej8mWoDUPGyVt7VdgPSeTz_8A_BJTpcfNvBN6Jqdv_ly8xeczcAGcTqHELDElakM-FWm07jkPdG-_OYsw==	\N	2000.00	Miami	2026-10-14 17:03:37.667967+05:30	\N	\N
477	Willh608	gAAAAABqz2iR0ymvadGxCZTMI-RzB6InoHRxH-_TmccA1ZAf0Oprjl_s1G1HYUbgiM5kosYcBg6nFvtsU2ZywG_hEcykxKrbKw==	\N	\N	Pennsylvania	2026-10-14 17:03:37.765148+05:30	\N	\N
482	BNT515	gAAAAABqz2iRpxPLYV-f7vNlYuuth4y-E7S5xL0difiZbk4RT3Xg_AuFZJub--hCEkJ8EFscmeW47G5gSz0n4GVgoHkNJ1_rsQ==	\N	\N	North Carolina	2026-10-14 17:03:37.86282+05:30	\N	\N
487	Bnt505	gAAAAABqz2iRrfZM3TooCUNyiYo-xHHBCv6tTbjlJuH1FJlTZlSMaV1uFeGcqDqfbrUAsTGhkxmSEMCybgEyR7wuUMeD9bF_JA==	\N	\N	\N	2026-10-14 17:03:37.996365+05:30	\N	\N
492	W89359	gAAAAABqz2iSwJlcgih3e2fOXla9ymQI1MA5pMCTQVFnIsr8ZKrMrb3XvqHNuiGPAGXX1La7W3bBE9FsdDx2HoBIjGr7vz8XTw==	\N	\N	NYC	2026-10-14 17:03:38.101027+05:30	\N	\N
497	Mj46	gAAAAABqz2iSCzFQUKWStmsFBqfFSO_bsqpPTohYVzwbSE8ZygiEZhsJJf6J5PYqeHgSNSkvOzqaJL2Xr3w1g28w_qlEZB48ow==	\N	\N	Dallas	2026-10-14 17:03:38.202976+05:30	\N	\N
502	Chris224	gAAAAABqz2iSiq4_lP3LHHj0A8rD77mWAGjjAY4-1YTZbPur7VcQH5dCr0wnMdcfoPUbdfs8PVPxbKbgsmvYBpDTYRyJiCKpmQ==	\N	\N	Dallas	2026-10-14 17:03:38.295983+05:30	\N	\N
507	Xjg4541	gAAAAABqz2iSJ36kQADJhbIWYxWR3fI2e6l8iSB8oaGCerOF-cOPBwPq9bGkafOcX_a4VaXteR172IvHaGrg-R5WVL2H4e__mA==	\N	\N	North Carolina	2026-10-14 17:03:38.39321+05:30	\N	\N
512	Cf221	gAAAAABqz2iS1PFAmtUPM5mmQvfyICyN8aAm09hKgT_Mf6e-57_8BOXx6-42vDPcBxP3l61EKLtWW7b1HoAgoG7cPVAAiwOryg==	\N	\N	Miami	2026-10-14 17:03:38.491167+05:30	\N	\N
517	Tn330	gAAAAABqz2iSLze0csF1WqeahFlipCMqQtuiKTWQCIq_9T6x05n3fvDNm1xr55EbN8GcYWlQtlC--hirdTvReeAC5AZ2GvkVOg==	\N	\N	\N	2026-10-14 17:03:38.607273+05:30	\N	\N
522	Pac1085	gAAAAABqz2iSBIXyDOaUitRr-0yHOQ7xWZ60CQBU5pXJz5ZyBOa-V8wte3JzoUiUjK0Dn_6XutP9_YieMMVKMT_UovCwazV-8w==	\N	\N	Washington	2026-10-14 17:03:38.715695+05:30	\N	\N
527	C12023	gAAAAABqz2iS8QY3BA2ntNOP4C0kznGzhBuANlB_n5jPRG5vwYMU8XzBUbhsIjoB4dSV6KGWE8cJHbGQ41yJrzySg_OumEqdgA==	\N	\N	Miami	2026-10-14 17:03:38.815696+05:30	\N	\N
532	Va114	gAAAAABqz2iSXCZvnJYPEHP82Pi9STs8znr8SLq3jFH09KTgaloK1drHxpFaI-h0Qo3OgTBGVdmX6xW-maeOlmriz-krmMkX5A==	\N	\N	North Carolina	2026-10-14 17:03:38.915466+05:30	\N	\N
537	Az109	gAAAAABqz2iT8Rurp5KAEJW50HuUawcjItVWV4VCjuFO6JJ0Qv2SLwfR4A0n8Cw0BwRN4rb0sxGwjhkuzVdjK-BMK9SwBfjBvA==	\N	\N	LA	2026-10-14 17:03:39.009027+05:30	\N	\N
542	Apo14	gAAAAABqz2iTIn4oSM2lYIJnKcK375esona8bMjOV8sdJyov7VJvFpYHv7pj5Wi4yf7RaLv5YKFlbDaVzYnS5ZZaYfxVEyHspg==	\N	\N	\N	2026-10-14 17:03:39.105132+05:30	\N	\N
547	XI1005	gAAAAABqz2iTRS53rbJyzwC1jSHs1aitinRVreIrFdscsO0f6KpfxYfVp_8wdl7UFI_tlshoPSgSYofZLTSII3c4EXwDyjs5bA==	\N	\N	LA	2026-10-14 17:03:39.214829+05:30	\N	\N
552	Kaf279	gAAAAABqz2iTaKsLW-Khos1QNT4sw17Z_z4dnVO8oYHp-DLF6VgTtFBk3F83pWnNHpNUucbZbaVFoVVZ2A0GSjFWtTLrNEN4hQ==	\N	\N	\N	2026-10-14 17:03:39.309566+05:30	\N	\N
557	Ml4	gAAAAABqz2iTQlkHmiTu3LhiQHnKkyO7LEtWMm4pdM7xTd4wjauXmz6_-cDk2sSk_95IZFxk6gHIYcyQGY-CFG3jDJ0RFUu5vQ==	1500.00	2000.00	Orlando	2026-10-14 17:03:39.406407+05:30	\N	\N
562	W59	gAAAAABqz2iTjmA2bOzrArARh957RAu7Vgaq3sdtjQGWq92Zw7LW-GZ83kjO4bCC-PeaZic2i57vB7Dw-wrTnCNp4fBnGLuMKQ==	1500.00	1000.00	Omaha	2026-10-14 17:03:39.499607+05:30	\N	\N
\.


--
-- Data for Name: admin_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_credentials (id, username, password_hash) FROM stdin;
1	admin	d56bc5b85793bc8722d057437df58d3c$42ec2d1d6dd9d927ee2ddb76934632edd13125c413ed35669b5d495a1954a034
\.


--
-- Data for Name: figures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.figures (id, party_id, account_id, figure, figure_date, start_date, end_date, entered_by, created_at) FROM stdin;
1	162	185	100.00	2026-10-14	\N	\N	1	2026-10-14 15:42:52.926341+05:30
2	162	177	450.00	2026-10-14	\N	\N	1	2026-10-14 15:48:16.079285+05:30
\.


--
-- Data for Name: parties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parties (id, kind, name, name_key, created_at) FROM stdin;
1	partner	Baws	baws	2026-10-13 16:53:00.198581+05:30
2	partner	SlumDog	slumdog	2026-10-13 16:53:00.217169+05:30
3	partner	Jon Bowman	jon bowman	2026-10-13 16:53:00.224092+05:30
4	partner	Arnone	arnone	2026-10-13 16:53:00.230151+05:30
5	partner	Sleepy	sleepy	2026-10-13 16:53:00.237692+05:30
6	partner	Ronak Patel	ronak patel	2026-10-13 16:53:00.244244+05:30
7	partner	Jack Sheplack	jack sheplack	2026-10-13 16:53:00.249996+05:30
8	partner	Brian Dunivant	brian dunivant	2026-10-13 16:53:00.255576+05:30
9	partner	Rudy De La Cruz	rudy de la cruz	2026-10-13 16:53:00.26154+05:30
10	partner	Paul C	paul c	2026-10-13 16:53:00.267486+05:30
11	partner	Paul C 2	paul c 2	2026-10-13 16:53:00.273187+05:30
12	partner	Alex Maroney	alex maroney	2026-10-13 16:53:00.2788+05:30
13	partner	Leech	leech	2026-10-13 16:53:00.285363+05:30
14	partner	Dylan Epinger	dylan epinger	2026-10-13 16:53:00.291792+05:30
15	partner	Cam D	cam d	2026-10-13 16:53:00.297197+05:30
16	partner	Tuan	tuan	2026-10-13 16:53:00.302621+05:30
17	partner	Sand	sand	2026-10-13 16:53:00.30917+05:30
18	partner	Blitzcrank	blitzcrank	2026-10-13 16:53:00.314845+05:30
19	partner	Noy	noy	2026-10-13 16:53:00.320689+05:30
20	partner	Brian Nguyen	brian nguyen	2026-10-13 16:53:00.325997+05:30
21	partner	Leo Martinez	leo martinez	2026-10-13 16:53:00.331471+05:30
22	partner	Tommy	tommy	2026-10-13 16:53:00.33862+05:30
23	partner	Tommy 2	tommy 2	2026-10-13 16:53:00.344124+05:30
24	partner	Michael Nicoletta	michael nicoletta	2026-10-13 16:53:00.349923+05:30
25	partner	Joe Cassidy	joe cassidy	2026-10-13 16:53:00.355659+05:30
26	partner	Sham	sham	2026-10-13 16:53:00.360945+05:30
27	partner	Jack C	jack c	2026-10-13 16:53:00.366915+05:30
28	partner	Dre	dre	2026-10-13 16:53:00.372668+05:30
29	partner	Dom Olinger	dom olinger	2026-10-13 16:53:00.377708+05:30
30	partner	Ryan Leal	ryan leal	2026-10-13 16:53:00.384149+05:30
31	partner	Rubika	rubika	2026-10-13 16:53:00.391259+05:30
32	partner	Justin Seidman	justin seidman	2026-10-13 16:53:00.396599+05:30
33	partner	Crypto	crypto	2026-10-13 16:53:00.402784+05:30
34	partner	BGORA	bgora	2026-10-13 16:53:00.408002+05:30
35	partner	BGORA 2	bgora 2	2026-10-13 16:53:00.414131+05:30
36	partner	Vinny	vinny	2026-10-13 16:53:00.420461+05:30
37	partner	Vinny 2	vinny 2	2026-10-13 16:53:00.425817+05:30
38	partner	Andy Reed	andy reed	2026-10-13 16:53:00.431938+05:30
39	partner	Pete	pete	2026-10-13 16:53:00.438987+05:30
40	partner	Devan	devan	2026-10-13 16:53:00.444601+05:30
41	partner	Warren	warren	2026-10-13 16:53:00.451825+05:30
42	partner	Andy Reed	andy reed	2026-10-13 16:53:00.458488+05:30
43	partner	Eugene Golubchik	eugene golubchik	2026-10-13 16:53:00.464594+05:30
44	partner	Matt Campos	matt campos	2026-10-13 16:53:00.469969+05:30
45	partner	Tyler F/Ben	tyler f/ben	2026-10-13 16:53:00.475769+05:30
46	partner	Eddie Lepore	eddie lepore	2026-10-13 16:53:00.481834+05:30
47	partner	Gabe Moskow	gabe moskow	2026-10-13 16:53:00.488645+05:30
48	partner	Spencer Stenger	spencer stenger	2026-10-13 16:53:00.494367+05:30
49	partner	Ryan Hogan	ryan hogan	2026-10-13 16:53:00.499979+05:30
50	partner	jamie	jamie	2026-10-13 16:53:00.505263+05:30
51	partner	Garrison	garrison	2026-10-13 16:53:00.511211+05:30
52	partner	Garrison 2	garrison 2	2026-10-13 16:53:00.516656+05:30
53	partner	Johnathan Schnitzer	johnathan schnitzer	2026-10-13 16:53:00.522072+05:30
54	partner	Johnathan Schnitzer	johnathan schnitzer	2026-10-13 16:53:00.527507+05:30
55	partner	Joey Callahan	joey callahan	2026-10-13 16:53:00.533625+05:30
56	partner	Pablo G Accounts	pablo g accounts	2026-10-13 16:53:00.541187+05:30
57	partner	Ryan Holtz	ryan holtz	2026-10-13 16:53:00.546661+05:30
58	partner	MAR	mar	2026-10-13 16:53:00.552245+05:30
59	partner	Decky	decky	2026-10-13 16:53:00.558261+05:30
60	partner	Rico	rico	2026-10-13 16:53:00.563726+05:30
61	partner	Donnie B Accounts	donnie b accounts	2026-10-13 16:53:00.576359+05:30
62	partner	Donnie B Accounts	donnie b accounts	2026-10-13 16:53:00.628172+05:30
63	partner	Erik Preuss	erik preuss	2026-10-13 16:53:00.638981+05:30
64	partner	Playtech	playtech	2026-10-13 16:53:00.648154+05:30
65	partner	Manny Fresco	manny fresco	2026-10-13 16:53:00.6597+05:30
66	partner	Tim	tim	2026-10-13 16:53:00.666516+05:30
67	partner	Sweiss	sweiss	2026-10-13 16:53:00.671693+05:30
68	partner	Ray Cordano	ray cordano	2026-10-13 16:53:00.676789+05:30
69	partner	Ray Cordano 2	ray cordano 2	2026-10-13 16:53:00.682981+05:30
70	partner	Ryan Kid	ryan kid	2026-10-13 16:53:00.68987+05:30
71	partner	Ben Bosker	ben bosker	2026-10-13 16:53:00.695362+05:30
72	partner	Ben Bosker 2	ben bosker 2	2026-10-13 16:53:00.701018+05:30
73	partner	Drago /Drago 2	drago /drago 2	2026-10-13 16:53:00.706324+05:30
74	partner	Jonathan	jonathan	2026-10-13 16:53:00.712183+05:30
75	partner	Jonathan 2	jonathan 2	2026-10-13 16:53:00.71906+05:30
76	partner	Josh Banuelos	josh banuelos	2026-10-13 16:53:00.724149+05:30
77	partner	Dylan/Dustin	dylan/dustin	2026-10-13 16:53:00.729863+05:30
78	partner	Hippy	hippy	2026-10-13 16:53:00.736891+05:30
79	partner	John S	john s	2026-10-13 16:53:00.743281+05:30
80	partner	Austin A	austin a	2026-10-13 16:53:00.749092+05:30
81	partner	Austin 2	austin 2	2026-10-13 16:53:00.754267+05:30
82	partner	Austin 3	austin 3	2026-10-13 16:53:00.75987+05:30
83	partner	Leaks	leaks	2026-10-13 16:53:00.76548+05:30
84	partner	Gerald Medina	gerald medina	2026-10-13 16:53:00.770519+05:30
85	partner	Sean Lorden	sean lorden	2026-10-13 16:53:00.776592+05:30
86	partner	Angus	angus	2026-10-13 16:53:00.782408+05:30
87	partner	Guapo	guapo	2026-10-13 16:53:00.789409+05:30
88	partner	Cutter	cutter	2026-10-13 16:53:00.795151+05:30
89	partner	Baylor	baylor	2026-10-13 16:53:00.800945+05:30
90	partner	WIlliam Watson	william watson	2026-10-13 16:53:00.806754+05:30
91	partner	Rece Gustafson	rece gustafson	2026-10-13 16:53:00.812466+05:30
92	partner	Marcus Schoepp	marcus schoepp	2026-10-13 16:53:00.818131+05:30
93	partner	Nolan	nolan	2026-10-13 16:53:00.823798+05:30
94	partner	Turtle	turtle	2026-10-13 16:53:00.828832+05:30
95	partner	Eddie	eddie	2026-10-13 16:53:00.835874+05:30
96	partner	Mike	mike	2026-10-13 16:53:00.842346+05:30
97	partner	Cade/Barrett	cade/barrett	2026-10-13 16:53:00.847834+05:30
98	partner	Sean Zeer	sean zeer	2026-10-13 16:53:00.853746+05:30
99	partner	Sean Zeer 2	sean zeer 2	2026-10-13 16:53:00.858949+05:30
100	partner	Jason /Trey	jason /trey	2026-10-13 16:53:00.864448+05:30
101	partner	Carlos	carlos	2026-10-13 16:53:00.870121+05:30
102	partner	Connor	connor	2026-10-13 16:53:00.875341+05:30
103	partner	Dad	dad	2026-10-13 16:53:00.880828+05:30
104	partner	Bro	bro	2026-10-13 16:53:00.88799+05:30
105	partner	BullDog	bulldog	2026-10-13 16:53:00.893424+05:30
106	partner	Andrew Gombas	andrew gombas	2026-10-13 16:53:00.899818+05:30
107	partner	Danny weez	danny weez	2026-10-13 16:53:00.905197+05:30
108	partner	Vinny Russo	vinny russo	2026-10-13 16:53:00.910958+05:30
109	partner	Hung	hung	2026-10-13 16:53:00.916799+05:30
110	partner	Hung 2	hung 2	2026-10-13 16:53:00.922418+05:30
111	partner	The Operation	the operation	2026-10-13 16:53:00.92747+05:30
112	partner	Blake Andrews	blake andrews	2026-10-13 16:53:00.934409+05:30
113	partner	Stone Joseph	stone joseph	2026-10-13 16:53:00.94318+05:30
114	partner	John nolen	john nolen	2026-10-13 16:53:00.952107+05:30
115	partner	Davis Cooper	davis cooper	2026-10-13 16:53:00.958286+05:30
116	partner	Will Uhrich	will uhrich	2026-10-13 16:53:00.964488+05:30
117	partner	Chandler Chaffee	chandler chaffee	2026-10-13 16:53:00.969776+05:30
118	partner	Ted Fernandez	ted fernandez	2026-10-13 16:53:00.974887+05:30
119	partner	Luke Hodgkinson	luke hodgkinson	2026-10-13 16:53:00.980891+05:30
120	partner	Spencer Blacksher	spencer blacksher	2026-10-13 16:53:00.986328+05:30
121	partner	Sam Georgiana	sam georgiana	2026-10-13 16:53:00.991857+05:30
122	partner	Ridds	ridds	2026-10-13 16:53:00.998322+05:30
123	partner	Grant Champman	grant champman	2026-10-13 16:53:01.004171+05:30
124	partner	Bru	bru	2026-10-13 16:53:01.010867+05:30
125	partner	Zach Stephen	zach stephen	2026-10-13 16:53:01.016572+05:30
126	partner	Ryan Baker	ryan baker	2026-10-13 16:53:01.021653+05:30
127	partner	Nick Mcadam	nick mcadam	2026-10-13 16:53:01.027954+05:30
128	partner	Vinny Nguyen	vinny nguyen	2026-10-13 16:53:01.033748+05:30
129	partner	Luke Hatfield	luke hatfield	2026-10-13 16:53:01.040186+05:30
130	partner	Reid Bolin	reid bolin	2026-10-13 16:53:01.046833+05:30
131	partner	Blake Martin	blake martin	2026-10-13 16:53:01.055199+05:30
132	partner	Zay	zay	2026-10-13 16:53:01.061967+05:30
133	partner	Braden	braden	2026-10-13 16:53:01.068971+05:30
134	partner	Zach Witcher	zach witcher	2026-10-13 16:53:01.076988+05:30
135	partner	CB	cb	2026-10-13 16:53:01.083417+05:30
136	partner	Shiv	shiv	2026-10-13 16:53:01.091088+05:30
137	partner	Shiv2	shiv2	2026-10-13 16:53:01.097693+05:30
138	partner	Max	max	2026-10-13 16:53:01.103751+05:30
139	partner	Josh F/Himothy	josh f/himothy	2026-10-13 16:53:01.108943+05:30
140	partner	Josh F/Himothy	josh f/himothy	2026-10-13 16:53:01.114419+05:30
141	partner	Shiv	shiv	2026-10-13 16:53:01.120235+05:30
142	partner	Shiv 2	shiv 2	2026-10-13 16:53:01.125321+05:30
143	partner	Sam Adlakha	sam adlakha	2026-10-13 16:53:01.13078+05:30
144	partner	James & D	james & d	2026-10-13 16:53:01.136237+05:30
145	partner	Noodles	noodles	2026-10-13 16:53:01.141304+05:30
146	partner	Mo's Accounts	mo's accounts	2026-10-13 16:53:01.147008+05:30
147	partner	Mo's 2	mo's 2	2026-10-13 16:53:01.15241+05:30
148	partner	Butters	butters	2026-10-13 16:53:01.158231+05:30
149	partner	Hien 1	hien 1	2026-10-13 16:53:01.165634+05:30
150	partner	Hien 2	hien 2	2026-10-13 16:53:01.173517+05:30
151	partner	Hien 3	hien 3	2026-10-13 16:53:01.179844+05:30
152	partner	Coffee's	coffee's	2026-10-13 16:53:01.187068+05:30
153	partner	Thieu 1	thieu 1	2026-10-13 16:53:01.196923+05:30
154	partner	Ginger	ginger	2026-10-13 16:53:01.203346+05:30
155	partner	Gerard 2	gerard 2	2026-10-13 16:53:01.209842+05:30
156	partner	Rabbit’s Accounts	rabbit’s accounts	2026-10-13 16:53:01.216423+05:30
157	partner	Rabbit’s 2	rabbit’s 2	2026-10-13 16:53:01.222325+05:30
158	partner	Rabbit’s 3	rabbit’s 3	2026-10-13 16:53:01.228665+05:30
159	partner	Hubert	hubert	2026-10-13 16:53:01.235336+05:30
160	partner	John	john	2026-10-13 16:53:01.240808+05:30
161	partner	Jack Proctor	jack proctor	2026-10-13 16:53:01.246042+05:30
162	partner	Ben Freeman	ben freeman	2026-10-13 16:53:01.25135+05:30
163	capper	Green	green	2026-10-13 17:06:08.039205+05:30
164	capper	Lime Green	lime green	2026-10-13 17:06:08.062772+05:30
165	capper	Yellow	yellow	2026-10-13 17:06:08.068785+05:30
166	capper	Light Yellow	light yellow	2026-10-13 17:06:08.074607+05:30
167	capper	Pink	pink	2026-10-13 17:06:08.081428+05:30
168	capper	Light Pink	light pink	2026-10-13 17:06:08.087297+05:30
169	capper	Purple	purple	2026-10-13 17:06:08.094229+05:30
170	capper	Red	red	2026-10-13 17:06:08.102311+05:30
171	capper	Grey	grey	2026-10-13 17:06:08.108979+05:30
172	capper	Black	black	2026-10-13 17:06:08.115266+05:30
173	capper	Orange	orange	2026-10-13 17:06:08.120937+05:30
174	capper	Light Orange	light orange	2026-10-13 17:06:08.127312+05:30
175	capper	Blue	blue	2026-10-13 17:06:08.133065+05:30
176	capper	Turquoise	turquoise	2026-10-13 17:06:08.138894+05:30
177	capper	Teal	teal	2026-10-13 17:06:08.146837+05:30
178	capper	Maroon	maroon	2026-10-13 17:06:08.153991+05:30
180	partner	Ty	ty	2026-10-14 16:57:12.526623+05:30
\.


--
-- Data for Name: party_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.party_accounts (id, party_id, account_id, created_at) FROM stdin;
3	178	1	2026-10-13 17:20:16.623684+05:30
7	172	3	2026-10-13 17:20:16.672921+05:30
9	171	4	2026-10-13 17:20:16.687884+05:30
11	169	5	2026-10-13 17:20:16.705406+05:30
13	163	6	2026-10-13 17:20:16.721327+05:30
15	176	7	2026-10-13 17:20:16.737008+05:30
17	178	8	2026-10-13 17:20:16.75165+05:30
20	169	9	2026-10-13 17:20:16.766766+05:30
22	176	10	2026-10-13 17:20:16.781046+05:30
24	175	11	2026-10-13 17:20:16.797641+05:30
25	165	11	2026-10-13 17:20:16.797642+05:30
26	169	11	2026-10-13 17:20:16.797643+05:30
28	176	12	2026-10-13 17:20:16.815636+05:30
30	176	13	2026-10-13 17:20:16.833925+05:30
32	167	14	2026-10-13 17:20:16.85096+05:30
34	172	15	2026-10-13 17:20:16.867399+05:30
36	165	16	2026-10-13 17:20:16.883315+05:30
37	163	16	2026-10-13 17:20:16.883316+05:30
39	172	17	2026-10-13 17:20:16.899977+05:30
41	172	18	2026-10-13 17:20:16.915619+05:30
43	172	19	2026-10-13 17:20:16.933381+05:30
45	166	20	2026-10-13 17:20:16.950697+05:30
49	171	22	2026-10-13 17:20:16.983426+05:30
51	175	23	2026-10-13 17:20:17.000388+05:30
53	178	24	2026-10-13 17:20:17.017018+05:30
55	171	25	2026-10-13 17:20:17.03309+05:30
58	172	27	2026-10-13 17:20:17.065052+05:30
79	174	1	2026-10-13 17:28:16.657193+05:30
80	1	48	2026-10-13 21:46:39.424985+05:30
81	171	48	2026-10-13 21:46:39.424987+05:30
82	2	49	2026-10-13 21:48:45.54923+05:30
83	171	49	2026-10-13 21:48:45.549232+05:30
84	168	49	2026-10-13 21:48:45.549233+05:30
85	2	50	2026-10-13 21:48:45.578856+05:30
86	171	50	2026-10-13 21:48:45.578859+05:30
87	3	51	2026-10-13 21:51:27.238338+05:30
88	163	51	2026-10-13 21:51:27.23834+05:30
89	168	51	2026-10-13 21:51:27.238341+05:30
90	177	51	2026-10-13 21:55:19.695067+05:30
91	4	52	2026-10-13 22:20:04.159239+05:30
92	164	52	2026-10-13 22:20:04.159242+05:30
93	4	53	2026-10-13 22:20:04.175891+05:30
94	166	53	2026-10-13 22:20:04.175894+05:30
95	4	54	2026-10-13 22:20:04.193159+05:30
96	167	54	2026-10-13 22:20:04.193162+05:30
97	4	55	2026-10-13 22:20:04.208767+05:30
98	167	55	2026-10-13 22:20:04.20877+05:30
99	4	56	2026-10-13 22:20:04.22704+05:30
100	178	56	2026-10-13 22:20:04.227043+05:30
101	4	57	2026-10-13 22:20:04.242639+05:30
102	176	57	2026-10-13 22:20:04.242642+05:30
103	4	58	2026-10-13 22:20:04.262333+05:30
104	176	58	2026-10-13 22:20:04.262335+05:30
105	5	59	2026-10-13 22:25:22.444916+05:30
106	175	59	2026-10-13 22:25:22.444919+05:30
107	6	60	2026-10-13 22:27:44.189023+05:30
108	165	60	2026-10-13 22:27:44.189026+05:30
109	168	60	2026-10-13 22:27:44.189027+05:30
110	6	61	2026-10-13 22:27:44.215836+05:30
111	163	61	2026-10-13 22:27:44.215839+05:30
112	6	62	2026-10-13 22:27:44.294359+05:30
113	163	62	2026-10-13 22:27:44.294361+05:30
114	6	63	2026-10-13 22:27:44.312503+05:30
115	171	63	2026-10-13 22:27:44.312506+05:30
116	6	64	2026-10-13 22:27:44.327341+05:30
117	171	64	2026-10-13 22:27:44.327343+05:30
118	6	65	2026-10-13 22:27:44.342797+05:30
119	171	65	2026-10-13 22:27:44.3428+05:30
120	6	66	2026-10-13 22:27:44.357323+05:30
121	163	66	2026-10-13 22:27:44.357325+05:30
122	174	66	2026-10-13 22:27:44.357326+05:30
123	6	67	2026-10-13 22:27:44.371674+05:30
124	171	67	2026-10-13 22:27:44.371677+05:30
125	168	67	2026-10-13 22:27:44.371678+05:30
126	6	68	2026-10-13 22:27:44.387372+05:30
127	165	68	2026-10-13 22:27:44.387375+05:30
128	168	68	2026-10-13 22:27:44.387375+05:30
129	7	69	2026-10-13 22:37:51.105603+05:30
130	165	69	2026-10-13 22:37:51.105623+05:30
131	7	70	2026-10-13 22:37:51.13124+05:30
132	171	70	2026-10-13 22:37:51.131243+05:30
133	7	71	2026-10-13 22:37:51.151695+05:30
134	169	71	2026-10-13 22:37:51.151698+05:30
135	7	72	2026-10-13 22:37:51.175283+05:30
136	163	72	2026-10-13 22:37:51.175287+05:30
137	8	73	2026-10-13 22:41:02.278073+05:30
138	167	73	2026-10-13 22:41:02.278077+05:30
139	163	73	2026-10-13 22:41:02.278077+05:30
140	9	74	2026-10-13 22:44:08.470242+05:30
141	174	74	2026-10-13 22:44:08.470244+05:30
142	178	74	2026-10-13 22:44:08.470245+05:30
143	9	75	2026-10-13 22:44:08.498407+05:30
144	169	75	2026-10-13 22:44:08.49841+05:30
145	10	76	2026-10-13 22:45:43.317+05:30
146	172	76	2026-10-13 22:45:43.317002+05:30
147	10	77	2026-10-13 22:45:43.34398+05:30
148	175	77	2026-10-13 22:45:43.343983+05:30
149	10	78	2026-10-13 22:45:43.36092+05:30
150	176	78	2026-10-13 22:45:43.360923+05:30
151	10	79	2026-10-13 22:45:43.376168+05:30
152	177	79	2026-10-13 22:45:43.37617+05:30
153	10	80	2026-10-13 22:45:43.395149+05:30
154	171	80	2026-10-13 22:45:43.395152+05:30
155	12	81	2026-10-14 11:58:17.794073+05:30
156	171	81	2026-10-14 11:58:17.794076+05:30
157	174	81	2026-10-14 11:58:17.794077+05:30
158	13	82	2026-10-14 12:13:17.645301+05:30
159	177	82	2026-10-14 12:13:17.645305+05:30
160	13	83	2026-10-14 12:13:17.676853+05:30
161	171	83	2026-10-14 12:13:17.676859+05:30
162	14	84	2026-10-14 13:05:28.473498+05:30
163	172	84	2026-10-14 13:05:28.473502+05:30
164	171	84	2026-10-14 13:05:28.473502+05:30
165	163	84	2026-10-14 13:05:28.473503+05:30
166	14	85	2026-10-14 13:05:28.494146+05:30
167	163	85	2026-10-14 13:05:28.494149+05:30
168	14	86	2026-10-14 13:05:28.516536+05:30
169	171	86	2026-10-14 13:05:28.51654+05:30
170	175	86	2026-10-14 13:05:28.516541+05:30
171	177	86	2026-10-14 13:05:28.516541+05:30
172	172	86	2026-10-14 13:05:28.516542+05:30
173	14	87	2026-10-14 13:05:28.534544+05:30
174	176	87	2026-10-14 13:05:28.534547+05:30
175	14	88	2026-10-14 13:05:28.550331+05:30
176	171	88	2026-10-14 13:05:28.550334+05:30
177	14	89	2026-10-14 13:05:28.567128+05:30
178	169	89	2026-10-14 13:05:28.567131+05:30
179	165	89	2026-10-14 13:05:28.567132+05:30
180	14	90	2026-10-14 13:05:28.583538+05:30
181	176	90	2026-10-14 13:05:28.583541+05:30
182	165	90	2026-10-14 13:05:28.583542+05:30
183	15	91	2026-10-14 13:15:31.284205+05:30
184	168	91	2026-10-14 13:15:31.284208+05:30
185	171	91	2026-10-14 13:15:31.284209+05:30
186	15	92	2026-10-14 13:15:31.311912+05:30
187	174	92	2026-10-14 13:15:31.311915+05:30
188	163	92	2026-10-14 13:15:31.311915+05:30
189	16	93	2026-10-14 14:45:38.7589+05:30
190	167	93	2026-10-14 14:45:38.758905+05:30
191	163	93	2026-10-14 14:45:38.758907+05:30
192	178	93	2026-10-14 14:45:38.758909+05:30
193	174	93	2026-10-14 14:45:38.75891+05:30
194	16	94	2026-10-14 14:45:38.797885+05:30
195	172	94	2026-10-14 14:45:38.797893+05:30
196	16	95	2026-10-14 14:45:38.840372+05:30
197	171	95	2026-10-14 14:45:38.840376+05:30
198	16	96	2026-10-14 14:45:38.863842+05:30
199	166	96	2026-10-14 14:45:38.863847+05:30
200	16	97	2026-10-14 14:45:38.889348+05:30
201	172	97	2026-10-14 14:45:38.889361+05:30
202	171	97	2026-10-14 14:45:38.889362+05:30
203	16	98	2026-10-14 14:45:38.919157+05:30
204	175	98	2026-10-14 14:45:38.91916+05:30
205	16	99	2026-10-14 14:45:38.942558+05:30
206	166	99	2026-10-14 14:45:38.942561+05:30
207	16	100	2026-10-14 14:45:38.968183+05:30
208	171	100	2026-10-14 14:45:38.968186+05:30
209	172	100	2026-10-14 14:45:38.968187+05:30
210	16	101	2026-10-14 14:45:38.986716+05:30
211	171	101	2026-10-14 14:45:38.98672+05:30
212	172	101	2026-10-14 14:45:38.986721+05:30
213	16	102	2026-10-14 14:45:39.010174+05:30
214	171	102	2026-10-14 14:45:39.010178+05:30
215	165	102	2026-10-14 14:45:39.010179+05:30
216	16	103	2026-10-14 14:45:39.0314+05:30
217	169	103	2026-10-14 14:45:39.031404+05:30
218	16	104	2026-10-14 14:45:39.054588+05:30
219	171	104	2026-10-14 14:45:39.054592+05:30
220	16	105	2026-10-14 14:45:39.073805+05:30
221	171	105	2026-10-14 14:45:39.073809+05:30
222	16	106	2026-10-14 14:45:39.089817+05:30
223	177	106	2026-10-14 14:45:39.08982+05:30
224	16	107	2026-10-14 14:45:39.106464+05:30
225	171	107	2026-10-14 14:45:39.106467+05:30
226	16	108	2026-10-14 14:45:39.127922+05:30
227	171	108	2026-10-14 14:45:39.127926+05:30
228	16	109	2026-10-14 14:45:39.158745+05:30
229	177	109	2026-10-14 14:45:39.158749+05:30
230	16	110	2026-10-14 14:45:39.190209+05:30
231	166	110	2026-10-14 14:45:39.19022+05:30
232	169	110	2026-10-14 14:45:39.190221+05:30
233	16	111	2026-10-14 14:45:39.221443+05:30
234	167	111	2026-10-14 14:45:39.221446+05:30
235	16	112	2026-10-14 14:45:39.254435+05:30
236	171	112	2026-10-14 14:45:39.254441+05:30
237	165	112	2026-10-14 14:45:39.254442+05:30
238	16	113	2026-10-14 14:45:39.280912+05:30
239	172	113	2026-10-14 14:45:39.280916+05:30
240	16	114	2026-10-14 14:45:39.305775+05:30
241	171	114	2026-10-14 14:45:39.30578+05:30
242	16	115	2026-10-14 14:45:39.335842+05:30
243	171	115	2026-10-14 14:45:39.335848+05:30
244	16	116	2026-10-14 14:45:39.371324+05:30
245	177	116	2026-10-14 14:45:39.371327+05:30
246	16	117	2026-10-14 14:45:39.39216+05:30
247	171	117	2026-10-14 14:45:39.392164+05:30
248	16	118	2026-10-14 14:45:39.419901+05:30
249	171	118	2026-10-14 14:45:39.419904+05:30
250	16	119	2026-10-14 14:45:39.437913+05:30
251	175	119	2026-10-14 14:45:39.437916+05:30
252	16	120	2026-10-14 14:45:39.455784+05:30
253	170	120	2026-10-14 14:45:39.455787+05:30
254	166	120	2026-10-14 14:45:39.455788+05:30
255	16	121	2026-10-14 14:45:39.477934+05:30
256	174	121	2026-10-14 14:45:39.477937+05:30
257	177	121	2026-10-14 14:45:39.477937+05:30
258	16	122	2026-10-14 14:45:39.50408+05:30
259	171	122	2026-10-14 14:45:39.504084+05:30
260	16	123	2026-10-14 14:45:39.533211+05:30
261	176	123	2026-10-14 14:45:39.533214+05:30
262	16	124	2026-10-14 14:45:39.549973+05:30
263	166	124	2026-10-14 14:45:39.549976+05:30
264	175	124	2026-10-14 14:45:39.549977+05:30
265	16	125	2026-10-14 14:45:39.575492+05:30
266	166	125	2026-10-14 14:45:39.575495+05:30
267	175	125	2026-10-14 14:45:39.575496+05:30
268	16	126	2026-10-14 14:45:39.601983+05:30
269	167	126	2026-10-14 14:45:39.601987+05:30
270	16	127	2026-10-14 14:45:39.635827+05:30
271	167	127	2026-10-14 14:45:39.635831+05:30
272	16	128	2026-10-14 14:45:39.657656+05:30
273	174	128	2026-10-14 14:45:39.657663+05:30
274	163	128	2026-10-14 14:45:39.657665+05:30
275	16	129	2026-10-14 14:45:39.685796+05:30
276	174	129	2026-10-14 14:45:39.6858+05:30
277	167	129	2026-10-14 14:45:39.685801+05:30
278	16	130	2026-10-14 14:45:39.707076+05:30
279	174	130	2026-10-14 14:45:39.707079+05:30
280	16	131	2026-10-14 14:45:39.738677+05:30
281	163	131	2026-10-14 14:45:39.738695+05:30
282	167	131	2026-10-14 14:45:39.738695+05:30
283	16	132	2026-10-14 14:45:39.769364+05:30
284	167	132	2026-10-14 14:45:39.769376+05:30
285	16	133	2026-10-14 14:45:39.793051+05:30
286	167	133	2026-10-14 14:45:39.793055+05:30
287	174	133	2026-10-14 14:45:39.793056+05:30
288	16	134	2026-10-14 14:45:39.819218+05:30
289	165	134	2026-10-14 14:45:39.819222+05:30
290	16	135	2026-10-14 14:45:39.840163+05:30
291	169	135	2026-10-14 14:45:39.840171+05:30
292	167	135	2026-10-14 14:45:39.840172+05:30
293	16	136	2026-10-14 14:45:39.87622+05:30
294	163	136	2026-10-14 14:45:39.876223+05:30
295	16	137	2026-10-14 14:45:39.90115+05:30
296	174	137	2026-10-14 14:45:39.901154+05:30
297	16	138	2026-10-14 14:45:39.925284+05:30
298	165	138	2026-10-14 14:45:39.925288+05:30
299	16	139	2026-10-14 14:45:39.944466+05:30
300	170	139	2026-10-14 14:45:39.94447+05:30
301	167	139	2026-10-14 14:45:39.94447+05:30
302	169	139	2026-10-14 14:45:39.944471+05:30
303	16	140	2026-10-14 14:45:39.971408+05:30
304	170	140	2026-10-14 14:45:39.971412+05:30
305	167	140	2026-10-14 14:45:39.971413+05:30
306	16	141	2026-10-14 14:45:39.991556+05:30
307	163	141	2026-10-14 14:45:39.99156+05:30
308	167	141	2026-10-14 14:45:39.991561+05:30
309	16	142	2026-10-14 14:45:40.02294+05:30
310	163	142	2026-10-14 14:45:40.022943+05:30
311	16	143	2026-10-14 14:45:40.048381+05:30
312	167	143	2026-10-14 14:45:40.048386+05:30
313	16	144	2026-10-14 14:45:40.079016+05:30
314	169	144	2026-10-14 14:45:40.07902+05:30
315	16	145	2026-10-14 14:45:40.105408+05:30
316	170	145	2026-10-14 14:45:40.105412+05:30
317	165	145	2026-10-14 14:45:40.105413+05:30
318	168	145	2026-10-14 14:45:40.105414+05:30
330	16	150	2026-10-14 14:45:40.226635+05:30
331	170	150	2026-10-14 14:45:40.226639+05:30
343	16	155	2026-10-14 14:45:40.338832+05:30
344	175	155	2026-10-14 14:45:40.338835+05:30
345	171	155	2026-10-14 14:45:40.338836+05:30
356	16	160	2026-10-14 14:45:40.435883+05:30
357	172	160	2026-10-14 14:45:40.435886+05:30
358	177	160	2026-10-14 14:45:40.435887+05:30
368	16	165	2026-10-14 14:45:40.524572+05:30
369	171	165	2026-10-14 14:45:40.524574+05:30
380	16	170	2026-10-14 14:45:40.616053+05:30
381	172	170	2026-10-14 14:45:40.616056+05:30
382	165	170	2026-10-14 14:45:40.616057+05:30
319	16	146	2026-10-14 14:45:40.129223+05:30
320	175	146	2026-10-14 14:45:40.129228+05:30
321	177	146	2026-10-14 14:45:40.129228+05:30
332	16	151	2026-10-14 14:45:40.245283+05:30
333	165	151	2026-10-14 14:45:40.245286+05:30
334	171	151	2026-10-14 14:45:40.245287+05:30
346	16	156	2026-10-14 14:45:40.360096+05:30
347	169	156	2026-10-14 14:45:40.360099+05:30
348	172	156	2026-10-14 14:45:40.3601+05:30
359	16	161	2026-10-14 14:45:40.458447+05:30
360	171	161	2026-10-14 14:45:40.45845+05:30
370	16	166	2026-10-14 14:45:40.540085+05:30
371	171	166	2026-10-14 14:45:40.540087+05:30
372	175	166	2026-10-14 14:45:40.540088+05:30
383	16	171	2026-10-14 14:45:40.633961+05:30
384	163	171	2026-10-14 14:45:40.633965+05:30
385	167	171	2026-10-14 14:45:40.633966+05:30
386	178	171	2026-10-14 14:45:40.633966+05:30
322	16	147	2026-10-14 14:45:40.154384+05:30
323	172	147	2026-10-14 14:45:40.15439+05:30
324	171	147	2026-10-14 14:45:40.154391+05:30
335	16	152	2026-10-14 14:45:40.26752+05:30
336	172	152	2026-10-14 14:45:40.267524+05:30
337	166	152	2026-10-14 14:45:40.267525+05:30
349	16	157	2026-10-14 14:45:40.38408+05:30
350	166	157	2026-10-14 14:45:40.384083+05:30
351	168	157	2026-10-14 14:45:40.384084+05:30
361	16	162	2026-10-14 14:45:40.473953+05:30
362	171	162	2026-10-14 14:45:40.473956+05:30
373	16	167	2026-10-14 14:45:40.558884+05:30
374	171	167	2026-10-14 14:45:40.558887+05:30
375	168	167	2026-10-14 14:45:40.558888+05:30
325	16	148	2026-10-14 14:45:40.177458+05:30
326	169	148	2026-10-14 14:45:40.177462+05:30
327	165	148	2026-10-14 14:45:40.177463+05:30
338	16	153	2026-10-14 14:45:40.288899+05:30
339	171	153	2026-10-14 14:45:40.288904+05:30
352	16	158	2026-10-14 14:45:40.402797+05:30
353	171	158	2026-10-14 14:45:40.4028+05:30
363	16	163	2026-10-14 14:45:40.489733+05:30
364	171	163	2026-10-14 14:45:40.489736+05:30
365	172	163	2026-10-14 14:45:40.489737+05:30
376	16	168	2026-10-14 14:45:40.57888+05:30
377	175	168	2026-10-14 14:45:40.578883+05:30
328	16	149	2026-10-14 14:45:40.200169+05:30
329	171	149	2026-10-14 14:45:40.200173+05:30
340	16	154	2026-10-14 14:45:40.316104+05:30
341	172	154	2026-10-14 14:45:40.316107+05:30
342	177	154	2026-10-14 14:45:40.316108+05:30
354	16	159	2026-10-14 14:45:40.420495+05:30
355	172	159	2026-10-14 14:45:40.420499+05:30
366	16	164	2026-10-14 14:45:40.507146+05:30
367	177	164	2026-10-14 14:45:40.507149+05:30
378	16	169	2026-10-14 14:45:40.595708+05:30
379	177	169	2026-10-14 14:45:40.595711+05:30
387	177	2	2026-10-14 15:04:59.993625+05:30
388	177	9	2026-10-14 15:05:00.033387+05:30
389	177	21	2026-10-14 15:05:00.047043+05:30
390	17	172	2026-10-14 15:26:15.267241+05:30
391	176	172	2026-10-14 15:26:15.267244+05:30
392	17	173	2026-10-14 15:26:15.285924+05:30
393	172	173	2026-10-14 15:26:15.285927+05:30
394	177	173	2026-10-14 15:26:15.285928+05:30
395	17	174	2026-10-14 15:26:15.3016+05:30
396	163	174	2026-10-14 15:26:15.301603+05:30
397	171	174	2026-10-14 15:26:15.301603+05:30
398	17	175	2026-10-14 15:26:15.318772+05:30
399	163	175	2026-10-14 15:26:15.318775+05:30
400	174	175	2026-10-14 15:26:15.318776+05:30
401	17	176	2026-10-14 15:26:15.334528+05:30
402	176	176	2026-10-14 15:26:15.334531+05:30
403	17	177	2026-10-14 15:26:15.34933+05:30
404	177	177	2026-10-14 15:26:15.349332+05:30
405	17	178	2026-10-14 15:26:15.366379+05:30
406	176	178	2026-10-14 15:26:15.366383+05:30
407	18	179	2026-10-14 15:26:15.383448+05:30
408	167	179	2026-10-14 15:26:15.383452+05:30
409	174	179	2026-10-14 15:26:15.383452+05:30
410	19	180	2026-10-14 15:26:15.400471+05:30
411	166	180	2026-10-14 15:26:15.400474+05:30
412	20	181	2026-10-14 15:26:15.414789+05:30
413	172	181	2026-10-14 15:26:15.414792+05:30
414	20	182	2026-10-14 15:26:15.429727+05:30
415	174	182	2026-10-14 15:26:15.42973+05:30
416	163	182	2026-10-14 15:26:15.42973+05:30
417	20	183	2026-10-14 15:26:15.444533+05:30
418	174	183	2026-10-14 15:26:15.444536+05:30
419	163	183	2026-10-14 15:26:15.444536+05:30
420	167	183	2026-10-14 15:26:15.444537+05:30
421	20	184	2026-10-14 15:26:15.460163+05:30
422	171	184	2026-10-14 15:26:15.460166+05:30
423	172	184	2026-10-14 15:26:15.460166+05:30
424	20	185	2026-10-14 15:26:15.474615+05:30
425	171	185	2026-10-14 15:26:15.474618+05:30
426	172	185	2026-10-14 15:26:15.474619+05:30
427	20	186	2026-10-14 15:26:15.490592+05:30
428	172	186	2026-10-14 15:26:15.490595+05:30
429	171	186	2026-10-14 15:26:15.490596+05:30
430	162	185	2026-10-14 15:42:42.0822+05:30
431	162	177	2026-10-14 15:48:05.031189+05:30
432	22	187	2026-10-14 15:57:43.153207+05:30
433	172	187	2026-10-14 15:57:43.153211+05:30
434	22	188	2026-10-14 15:57:43.183616+05:30
435	22	189	2026-10-14 15:57:43.21421+05:30
436	172	189	2026-10-14 15:57:43.214214+05:30
437	24	190	2026-10-14 15:57:43.291627+05:30
438	163	190	2026-10-14 15:57:43.291633+05:30
439	24	191	2026-10-14 15:57:43.318023+05:30
440	171	191	2026-10-14 15:57:43.318027+05:30
441	24	192	2026-10-14 15:57:43.342753+05:30
442	171	192	2026-10-14 15:57:43.342757+05:30
443	168	192	2026-10-14 15:57:43.342758+05:30
444	25	193	2026-10-14 15:57:43.364457+05:30
445	167	193	2026-10-14 15:57:43.364461+05:30
446	163	193	2026-10-14 15:57:43.364462+05:30
447	172	193	2026-10-14 15:57:43.364463+05:30
448	26	194	2026-10-14 15:57:43.386017+05:30
449	163	194	2026-10-14 15:57:43.386021+05:30
450	26	195	2026-10-14 15:57:43.406311+05:30
451	163	195	2026-10-14 15:57:43.406315+05:30
452	26	196	2026-10-14 15:57:43.429872+05:30
453	166	196	2026-10-14 15:57:43.429876+05:30
454	175	196	2026-10-14 15:57:43.429877+05:30
455	35	29	2026-10-14 16:45:29.424499+05:30
457	35	30	2026-10-14 16:45:29.449329+05:30
459	35	31	2026-10-14 16:45:29.475472+05:30
461	35	32	2026-10-14 16:45:29.493207+05:30
463	35	33	2026-10-14 16:45:29.520509+05:30
465	35	34	2026-10-14 16:45:29.544446+05:30
467	35	35	2026-10-14 16:45:29.560279+05:30
469	35	36	2026-10-14 16:45:29.579506+05:30
471	35	37	2026-10-14 16:45:29.596646+05:30
473	35	38	2026-10-14 16:45:29.616287+05:30
475	35	39	2026-10-14 16:45:29.635476+05:30
477	27	197	2026-10-14 16:45:29.839233+05:30
478	175	197	2026-10-14 16:45:29.839236+05:30
479	27	198	2026-10-14 16:45:29.856805+05:30
480	175	198	2026-10-14 16:45:29.856808+05:30
481	27	199	2026-10-14 16:45:29.87239+05:30
482	27	200	2026-10-14 16:45:29.888744+05:30
483	167	200	2026-10-14 16:45:29.888747+05:30
484	27	201	2026-10-14 16:45:29.905842+05:30
485	176	201	2026-10-14 16:45:29.905845+05:30
486	27	202	2026-10-14 16:45:29.923932+05:30
487	167	202	2026-10-14 16:45:29.923935+05:30
488	163	202	2026-10-14 16:45:29.923935+05:30
489	27	203	2026-10-14 16:45:29.940374+05:30
490	176	203	2026-10-14 16:45:29.940376+05:30
491	168	203	2026-10-14 16:45:29.940377+05:30
492	27	204	2026-10-14 16:45:29.957752+05:30
493	167	204	2026-10-14 16:45:29.957755+05:30
494	163	204	2026-10-14 16:45:29.957756+05:30
495	27	205	2026-10-14 16:45:29.979417+05:30
496	163	205	2026-10-14 16:45:29.979423+05:30
497	27	206	2026-10-14 16:45:30.003172+05:30
498	167	206	2026-10-14 16:45:30.003176+05:30
499	169	206	2026-10-14 16:45:30.003176+05:30
500	28	207	2026-10-14 16:45:30.022023+05:30
501	172	207	2026-10-14 16:45:30.022027+05:30
502	169	207	2026-10-14 16:45:30.022027+05:30
503	28	208	2026-10-14 16:45:30.041094+05:30
504	171	208	2026-10-14 16:45:30.041097+05:30
505	165	208	2026-10-14 16:45:30.041098+05:30
506	28	209	2026-10-14 16:45:30.05893+05:30
507	175	209	2026-10-14 16:45:30.058933+05:30
508	171	209	2026-10-14 16:45:30.058934+05:30
509	29	210	2026-10-14 16:45:30.07767+05:30
510	167	210	2026-10-14 16:45:30.077674+05:30
511	29	211	2026-10-14 16:45:30.131311+05:30
512	171	211	2026-10-14 16:45:30.131316+05:30
513	29	212	2026-10-14 16:45:30.157608+05:30
514	163	212	2026-10-14 16:45:30.157613+05:30
515	29	213	2026-10-14 16:45:30.179752+05:30
516	167	213	2026-10-14 16:45:30.179756+05:30
517	29	214	2026-10-14 16:45:30.202708+05:30
518	171	214	2026-10-14 16:45:30.202712+05:30
519	175	214	2026-10-14 16:45:30.202713+05:30
520	29	215	2026-10-14 16:45:30.222163+05:30
521	176	215	2026-10-14 16:45:30.222167+05:30
522	30	216	2026-10-14 16:45:30.240314+05:30
523	171	216	2026-10-14 16:45:30.240317+05:30
524	177	216	2026-10-14 16:45:30.240318+05:30
525	163	216	2026-10-14 16:45:30.240319+05:30
526	30	217	2026-10-14 16:45:30.26446+05:30
527	171	217	2026-10-14 16:45:30.264464+05:30
528	174	217	2026-10-14 16:45:30.264465+05:30
529	31	218	2026-10-14 16:45:30.282732+05:30
530	178	218	2026-10-14 16:45:30.282735+05:30
531	163	218	2026-10-14 16:45:30.282736+05:30
532	32	219	2026-10-14 16:45:30.301999+05:30
533	167	219	2026-10-14 16:45:30.302002+05:30
534	163	219	2026-10-14 16:45:30.302003+05:30
542	34	224	2026-10-14 16:45:30.396863+05:30
543	172	224	2026-10-14 16:45:30.396866+05:30
553	34	229	2026-10-14 16:45:30.4978+05:30
554	172	229	2026-10-14 16:45:30.497804+05:30
535	32	220	2026-10-14 16:45:30.320233+05:30
536	167	220	2026-10-14 16:45:30.320236+05:30
544	34	225	2026-10-14 16:45:30.416818+05:30
545	172	225	2026-10-14 16:45:30.416822+05:30
546	171	225	2026-10-14 16:45:30.416823+05:30
555	34	230	2026-10-14 16:45:30.517069+05:30
556	171	230	2026-10-14 16:45:30.517072+05:30
557	166	230	2026-10-14 16:45:30.517073+05:30
537	33	221	2026-10-14 16:45:30.340406+05:30
547	34	226	2026-10-14 16:45:30.437255+05:30
548	171	226	2026-10-14 16:45:30.437259+05:30
558	34	231	2026-10-14 16:45:30.534525+05:30
559	171	231	2026-10-14 16:45:30.534528+05:30
538	34	222	2026-10-14 16:45:30.35774+05:30
539	177	222	2026-10-14 16:45:30.357743+05:30
549	34	227	2026-10-14 16:45:30.457073+05:30
550	177	227	2026-10-14 16:45:30.457077+05:30
560	34	232	2026-10-14 16:45:30.553718+05:30
561	177	232	2026-10-14 16:45:30.553721+05:30
540	34	223	2026-10-14 16:45:30.378541+05:30
541	171	223	2026-10-14 16:45:30.378545+05:30
551	34	228	2026-10-14 16:45:30.478233+05:30
552	172	228	2026-10-14 16:45:30.478237+05:30
562	180	1	2026-10-14 16:57:12.54094+05:30
563	180	2	2026-10-14 16:57:12.554593+05:30
564	180	3	2026-10-14 16:57:12.567974+05:30
565	180	4	2026-10-14 16:57:12.581134+05:30
566	180	5	2026-10-14 16:57:12.593998+05:30
567	180	6	2026-10-14 16:57:12.607193+05:30
568	180	7	2026-10-14 16:57:12.620487+05:30
569	180	8	2026-10-14 16:57:12.633385+05:30
570	180	9	2026-10-14 16:57:12.646112+05:30
571	180	10	2026-10-14 16:57:12.658191+05:30
572	180	11	2026-10-14 16:57:12.670466+05:30
573	180	12	2026-10-14 16:57:12.682531+05:30
574	180	13	2026-10-14 16:57:12.694847+05:30
575	180	14	2026-10-14 16:57:12.706863+05:30
576	180	15	2026-10-14 16:57:12.718908+05:30
577	180	16	2026-10-14 16:57:12.73264+05:30
578	180	17	2026-10-14 16:57:12.745147+05:30
579	180	18	2026-10-14 16:57:12.757633+05:30
580	180	19	2026-10-14 16:57:12.770143+05:30
581	180	20	2026-10-14 16:57:12.782977+05:30
582	180	21	2026-10-14 16:57:12.795594+05:30
583	180	22	2026-10-14 16:57:12.807857+05:30
584	180	23	2026-10-14 16:57:12.820076+05:30
585	180	24	2026-10-14 16:57:12.832198+05:30
586	180	25	2026-10-14 16:57:12.844601+05:30
587	180	26	2026-10-14 16:57:12.856819+05:30
588	180	27	2026-10-14 16:57:12.869043+05:30
589	180	28	2026-10-14 16:57:12.881247+05:30
590	180	29	2026-10-14 16:57:12.89335+05:30
591	180	30	2026-10-14 16:57:12.905583+05:30
592	180	31	2026-10-14 16:57:12.918038+05:30
593	180	32	2026-10-14 16:57:12.932398+05:30
594	180	33	2026-10-14 16:57:12.944905+05:30
595	180	34	2026-10-14 16:57:12.958427+05:30
596	180	35	2026-10-14 16:57:12.972958+05:30
597	180	36	2026-10-14 16:57:12.985409+05:30
598	180	37	2026-10-14 16:57:12.998741+05:30
599	180	38	2026-10-14 16:57:13.012016+05:30
600	180	39	2026-10-14 16:57:13.024277+05:30
601	180	40	2026-10-14 16:57:13.036293+05:30
602	180	41	2026-10-14 16:57:13.049091+05:30
603	180	42	2026-10-14 16:57:13.062113+05:30
604	180	43	2026-10-14 16:57:13.074782+05:30
605	180	44	2026-10-14 16:57:13.086778+05:30
606	180	45	2026-10-14 16:57:13.100854+05:30
607	180	46	2026-10-14 16:57:13.114376+05:30
608	180	47	2026-10-14 16:57:13.127177+05:30
609	36	233	2026-10-14 17:03:32.934371+05:30
610	176	233	2026-10-14 17:03:32.934376+05:30
611	171	233	2026-10-14 17:03:32.934377+05:30
612	36	234	2026-10-14 17:03:32.958422+05:30
613	172	234	2026-10-14 17:03:32.958425+05:30
614	37	235	2026-10-14 17:03:32.977091+05:30
615	37	236	2026-10-14 17:03:32.992314+05:30
616	37	237	2026-10-14 17:03:33.008134+05:30
617	39	238	2026-10-14 17:03:33.028467+05:30
618	165	238	2026-10-14 17:03:33.028472+05:30
619	39	239	2026-10-14 17:03:33.047606+05:30
620	165	239	2026-10-14 17:03:33.04761+05:30
621	163	239	2026-10-14 17:03:33.047611+05:30
622	39	240	2026-10-14 17:03:33.067152+05:30
623	175	240	2026-10-14 17:03:33.067155+05:30
624	39	241	2026-10-14 17:03:33.085389+05:30
625	171	241	2026-10-14 17:03:33.085393+05:30
626	39	242	2026-10-14 17:03:33.104759+05:30
627	175	242	2026-10-14 17:03:33.104763+05:30
628	168	242	2026-10-14 17:03:33.104764+05:30
629	39	243	2026-10-14 17:03:33.122698+05:30
630	165	243	2026-10-14 17:03:33.122702+05:30
631	39	244	2026-10-14 17:03:33.143263+05:30
632	171	244	2026-10-14 17:03:33.143268+05:30
633	39	245	2026-10-14 17:03:33.163421+05:30
634	171	245	2026-10-14 17:03:33.163425+05:30
635	168	245	2026-10-14 17:03:33.163426+05:30
636	177	245	2026-10-14 17:03:33.163427+05:30
637	39	246	2026-10-14 17:03:33.182152+05:30
638	177	246	2026-10-14 17:03:33.182156+05:30
639	175	246	2026-10-14 17:03:33.182157+05:30
640	39	247	2026-10-14 17:03:33.258449+05:30
641	171	247	2026-10-14 17:03:33.258453+05:30
642	39	248	2026-10-14 17:03:33.292419+05:30
643	175	248	2026-10-14 17:03:33.292426+05:30
644	39	249	2026-10-14 17:03:33.325096+05:30
645	165	249	2026-10-14 17:03:33.325102+05:30
646	39	250	2026-10-14 17:03:33.348645+05:30
647	169	250	2026-10-14 17:03:33.348649+05:30
648	39	251	2026-10-14 17:03:33.373867+05:30
649	170	251	2026-10-14 17:03:33.373871+05:30
650	40	252	2026-10-14 17:03:33.394721+05:30
651	168	252	2026-10-14 17:03:33.394729+05:30
652	40	253	2026-10-14 17:03:33.416548+05:30
653	163	253	2026-10-14 17:03:33.416552+05:30
654	174	253	2026-10-14 17:03:33.416553+05:30
655	38	254	2026-10-14 17:03:33.435956+05:30
656	167	254	2026-10-14 17:03:33.43596+05:30
657	163	254	2026-10-14 17:03:33.435961+05:30
658	43	255	2026-10-14 17:03:33.454541+05:30
659	44	256	2026-10-14 17:03:33.471499+05:30
660	163	256	2026-10-14 17:03:33.471503+05:30
661	167	256	2026-10-14 17:03:33.471504+05:30
662	44	257	2026-10-14 17:03:33.491624+05:30
663	168	257	2026-10-14 17:03:33.491628+05:30
664	165	257	2026-10-14 17:03:33.491629+05:30
665	163	257	2026-10-14 17:03:33.49163+05:30
666	44	258	2026-10-14 17:03:33.510883+05:30
667	171	258	2026-10-14 17:03:33.510888+05:30
668	165	258	2026-10-14 17:03:33.510889+05:30
669	45	259	2026-10-14 17:03:33.530984+05:30
670	175	259	2026-10-14 17:03:33.530988+05:30
671	166	259	2026-10-14 17:03:33.530989+05:30
672	45	260	2026-10-14 17:03:33.549767+05:30
673	163	260	2026-10-14 17:03:33.54977+05:30
674	45	261	2026-10-14 17:03:33.568411+05:30
675	168	261	2026-10-14 17:03:33.568415+05:30
676	45	262	2026-10-14 17:03:33.588039+05:30
677	176	262	2026-10-14 17:03:33.588043+05:30
678	45	263	2026-10-14 17:03:33.606645+05:30
679	175	263	2026-10-14 17:03:33.606649+05:30
680	45	264	2026-10-14 17:03:33.628386+05:30
681	175	264	2026-10-14 17:03:33.628391+05:30
682	45	265	2026-10-14 17:03:33.646149+05:30
683	176	265	2026-10-14 17:03:33.646152+05:30
684	45	266	2026-10-14 17:03:33.66468+05:30
685	175	266	2026-10-14 17:03:33.664684+05:30
686	45	267	2026-10-14 17:03:33.682434+05:30
687	176	267	2026-10-14 17:03:33.682437+05:30
688	45	268	2026-10-14 17:03:33.70141+05:30
689	168	268	2026-10-14 17:03:33.701413+05:30
690	45	269	2026-10-14 17:03:33.719341+05:30
691	175	269	2026-10-14 17:03:33.719345+05:30
692	45	270	2026-10-14 17:03:33.740097+05:30
693	175	270	2026-10-14 17:03:33.740102+05:30
694	45	271	2026-10-14 17:03:33.758539+05:30
695	167	271	2026-10-14 17:03:33.758542+05:30
696	45	272	2026-10-14 17:03:33.777311+05:30
697	169	272	2026-10-14 17:03:33.777315+05:30
698	176	272	2026-10-14 17:03:33.777316+05:30
699	45	273	2026-10-14 17:03:33.798552+05:30
700	176	273	2026-10-14 17:03:33.798556+05:30
701	45	274	2026-10-14 17:03:33.817568+05:30
702	175	274	2026-10-14 17:03:33.817572+05:30
703	177	274	2026-10-14 17:03:33.817573+05:30
704	45	275	2026-10-14 17:03:33.836586+05:30
705	163	275	2026-10-14 17:03:33.83659+05:30
706	45	276	2026-10-14 17:03:33.855987+05:30
707	163	276	2026-10-14 17:03:33.85599+05:30
708	45	277	2026-10-14 17:03:33.87709+05:30
709	175	277	2026-10-14 17:03:33.877094+05:30
710	45	278	2026-10-14 17:03:33.895842+05:30
711	169	278	2026-10-14 17:03:33.895845+05:30
712	45	279	2026-10-14 17:03:33.916091+05:30
713	163	279	2026-10-14 17:03:33.916094+05:30
714	45	280	2026-10-14 17:03:33.934178+05:30
715	177	280	2026-10-14 17:03:33.934181+05:30
725	45	285	2026-10-14 17:03:34.031115+05:30
726	163	285	2026-10-14 17:03:34.031119+05:30
727	167	285	2026-10-14 17:03:34.031119+05:30
737	45	290	2026-10-14 17:03:34.128559+05:30
738	172	290	2026-10-14 17:03:34.128564+05:30
749	45	295	2026-10-14 17:03:34.227897+05:30
750	177	295	2026-10-14 17:03:34.227901+05:30
751	175	295	2026-10-14 17:03:34.227902+05:30
761	45	300	2026-10-14 17:03:34.323762+05:30
762	163	300	2026-10-14 17:03:34.323766+05:30
763	169	300	2026-10-14 17:03:34.323766+05:30
773	45	305	2026-10-14 17:03:34.423448+05:30
774	177	305	2026-10-14 17:03:34.423451+05:30
775	165	305	2026-10-14 17:03:34.423452+05:30
786	45	310	2026-10-14 17:03:34.520762+05:30
787	175	310	2026-10-14 17:03:34.520766+05:30
788	177	310	2026-10-14 17:03:34.520767+05:30
799	45	315	2026-10-14 17:03:34.615206+05:30
800	177	315	2026-10-14 17:03:34.615209+05:30
813	45	320	2026-10-14 17:03:34.709693+05:30
814	163	320	2026-10-14 17:03:34.709697+05:30
815	165	320	2026-10-14 17:03:34.709697+05:30
826	45	325	2026-10-14 17:03:34.804153+05:30
827	168	325	2026-10-14 17:03:34.804156+05:30
828	164	325	2026-10-14 17:03:34.804157+05:30
839	45	330	2026-10-14 17:03:34.899846+05:30
840	176	330	2026-10-14 17:03:34.89985+05:30
852	45	335	2026-10-14 17:03:35.000132+05:30
853	163	335	2026-10-14 17:03:35.000136+05:30
862	45	340	2026-10-14 17:03:35.105143+05:30
863	169	340	2026-10-14 17:03:35.105146+05:30
864	177	340	2026-10-14 17:03:35.105147+05:30
875	45	345	2026-10-14 17:03:35.207005+05:30
876	168	345	2026-10-14 17:03:35.207008+05:30
877	163	345	2026-10-14 17:03:35.207009+05:30
887	45	350	2026-10-14 17:03:35.315187+05:30
888	177	350	2026-10-14 17:03:35.315191+05:30
897	45	355	2026-10-14 17:03:35.418088+05:30
898	176	355	2026-10-14 17:03:35.418092+05:30
911	45	360	2026-10-14 17:03:35.522561+05:30
912	172	360	2026-10-14 17:03:35.522566+05:30
922	45	365	2026-10-14 17:03:35.623492+05:30
923	168	365	2026-10-14 17:03:35.623495+05:30
924	177	365	2026-10-14 17:03:35.623496+05:30
933	45	370	2026-10-14 17:03:35.718887+05:30
934	172	370	2026-10-14 17:03:35.718891+05:30
944	45	375	2026-10-14 17:03:35.813308+05:30
945	168	375	2026-10-14 17:03:35.813312+05:30
955	45	380	2026-10-14 17:03:35.911496+05:30
956	172	380	2026-10-14 17:03:35.911501+05:30
967	45	385	2026-10-14 17:03:36.009266+05:30
968	177	385	2026-10-14 17:03:36.009269+05:30
969	175	385	2026-10-14 17:03:36.00927+05:30
979	45	390	2026-10-14 17:03:36.107968+05:30
980	177	390	2026-10-14 17:03:36.107972+05:30
990	45	395	2026-10-14 17:03:36.205443+05:30
991	168	395	2026-10-14 17:03:36.205447+05:30
1002	45	400	2026-10-14 17:03:36.302716+05:30
1003	166	400	2026-10-14 17:03:36.30272+05:30
1012	45	405	2026-10-14 17:03:36.395313+05:30
1013	163	405	2026-10-14 17:03:36.395317+05:30
1023	45	410	2026-10-14 17:03:36.492644+05:30
1024	163	410	2026-10-14 17:03:36.492648+05:30
1036	45	415	2026-10-14 17:03:36.589925+05:30
1037	175	415	2026-10-14 17:03:36.589928+05:30
1038	177	415	2026-10-14 17:03:36.589929+05:30
1050	45	420	2026-10-14 17:03:36.686917+05:30
1051	167	420	2026-10-14 17:03:36.686921+05:30
1064	45	425	2026-10-14 17:03:36.782622+05:30
1065	166	425	2026-10-14 17:03:36.782625+05:30
1074	45	430	2026-10-14 17:03:36.876466+05:30
1075	175	430	2026-10-14 17:03:36.876469+05:30
1086	45	435	2026-10-14 17:03:36.970542+05:30
1087	168	435	2026-10-14 17:03:36.970545+05:30
1088	177	435	2026-10-14 17:03:36.970546+05:30
1099	45	440	2026-10-14 17:03:37.06661+05:30
1100	168	440	2026-10-14 17:03:37.066613+05:30
1109	45	445	2026-10-14 17:03:37.159139+05:30
1110	177	445	2026-10-14 17:03:37.159142+05:30
1111	163	445	2026-10-14 17:03:37.159143+05:30
1121	45	450	2026-10-14 17:03:37.254273+05:30
1122	175	450	2026-10-14 17:03:37.254276+05:30
1134	45	455	2026-10-14 17:03:37.34805+05:30
1135	177	455	2026-10-14 17:03:37.348054+05:30
1147	45	460	2026-10-14 17:03:37.444632+05:30
1148	177	460	2026-10-14 17:03:37.444636+05:30
1149	165	460	2026-10-14 17:03:37.444637+05:30
1158	45	465	2026-10-14 17:03:37.539083+05:30
1159	177	465	2026-10-14 17:03:37.539086+05:30
1170	45	470	2026-10-14 17:03:37.634564+05:30
1171	172	470	2026-10-14 17:03:37.634568+05:30
1180	45	475	2026-10-14 17:03:37.730287+05:30
1181	175	475	2026-10-14 17:03:37.730291+05:30
1182	177	475	2026-10-14 17:03:37.730292+05:30
1183	166	475	2026-10-14 17:03:37.730293+05:30
1197	45	480	2026-10-14 17:03:37.827786+05:30
1198	175	480	2026-10-14 17:03:37.82779+05:30
1199	177	480	2026-10-14 17:03:37.82779+05:30
1210	45	485	2026-10-14 17:03:37.953652+05:30
1211	163	485	2026-10-14 17:03:37.953656+05:30
1212	165	485	2026-10-14 17:03:37.953657+05:30
1224	45	490	2026-10-14 17:03:38.064117+05:30
1225	166	490	2026-10-14 17:03:38.064123+05:30
1235	45	495	2026-10-14 17:03:38.165072+05:30
1236	163	495	2026-10-14 17:03:38.165076+05:30
1245	45	500	2026-10-14 17:03:38.260562+05:30
1246	166	500	2026-10-14 17:03:38.260566+05:30
1258	45	505	2026-10-14 17:03:38.358615+05:30
1259	165	505	2026-10-14 17:03:38.358618+05:30
1268	45	510	2026-10-14 17:03:38.455908+05:30
1269	176	510	2026-10-14 17:03:38.455911+05:30
1279	45	515	2026-10-14 17:03:38.553306+05:30
1280	172	515	2026-10-14 17:03:38.55331+05:30
1281	169	515	2026-10-14 17:03:38.553311+05:30
1291	45	520	2026-10-14 17:03:38.680624+05:30
1292	176	520	2026-10-14 17:03:38.680628+05:30
1293	175	520	2026-10-14 17:03:38.680629+05:30
1303	45	525	2026-10-14 17:03:38.779323+05:30
1304	175	525	2026-10-14 17:03:38.779327+05:30
1305	165	525	2026-10-14 17:03:38.779328+05:30
1314	45	530	2026-10-14 17:03:38.878004+05:30
1315	163	530	2026-10-14 17:03:38.878008+05:30
1323	45	535	2026-10-14 17:03:38.97447+05:30
1324	177	535	2026-10-14 17:03:38.974474+05:30
1334	45	540	2026-10-14 17:03:39.071184+05:30
1335	165	540	2026-10-14 17:03:39.071187+05:30
1347	45	545	2026-10-14 17:03:39.171447+05:30
1348	168	545	2026-10-14 17:03:39.171454+05:30
1358	45	550	2026-10-14 17:03:39.27589+05:30
1359	167	550	2026-10-14 17:03:39.275894+05:30
1360	163	550	2026-10-14 17:03:39.275895+05:30
1370	46	555	2026-10-14 17:03:39.367876+05:30
1371	166	555	2026-10-14 17:03:39.36788+05:30
1384	48	560	2026-10-14 17:03:39.463868+05:30
1385	165	560	2026-10-14 17:03:39.463872+05:30
1386	175	560	2026-10-14 17:03:39.463873+05:30
716	45	281	2026-10-14 17:03:33.953471+05:30
717	167	281	2026-10-14 17:03:33.953475+05:30
718	163	281	2026-10-14 17:03:33.953475+05:30
728	45	286	2026-10-14 17:03:34.050722+05:30
729	177	286	2026-10-14 17:03:34.050726+05:30
739	45	291	2026-10-14 17:03:34.149038+05:30
740	172	291	2026-10-14 17:03:34.149042+05:30
741	165	291	2026-10-14 17:03:34.149042+05:30
742	166	291	2026-10-14 17:03:34.149043+05:30
752	45	296	2026-10-14 17:03:34.247687+05:30
753	177	296	2026-10-14 17:03:34.247691+05:30
754	175	296	2026-10-14 17:03:34.247692+05:30
764	45	301	2026-10-14 17:03:34.346043+05:30
765	172	301	2026-10-14 17:03:34.346049+05:30
776	45	306	2026-10-14 17:03:34.442263+05:30
777	177	306	2026-10-14 17:03:34.442267+05:30
789	45	311	2026-10-14 17:03:34.538249+05:30
790	175	311	2026-10-14 17:03:34.538252+05:30
791	177	311	2026-10-14 17:03:34.538253+05:30
801	45	316	2026-10-14 17:03:34.634113+05:30
802	165	316	2026-10-14 17:03:34.634116+05:30
803	177	316	2026-10-14 17:03:34.634117+05:30
816	45	321	2026-10-14 17:03:34.727793+05:30
817	168	321	2026-10-14 17:03:34.727797+05:30
818	163	321	2026-10-14 17:03:34.727798+05:30
829	45	326	2026-10-14 17:03:34.822252+05:30
830	168	326	2026-10-14 17:03:34.822255+05:30
831	163	326	2026-10-14 17:03:34.822256+05:30
841	45	331	2026-10-14 17:03:34.921269+05:30
842	169	331	2026-10-14 17:03:34.921274+05:30
843	167	331	2026-10-14 17:03:34.921275+05:30
854	45	336	2026-10-14 17:03:35.02218+05:30
855	167	336	2026-10-14 17:03:35.022184+05:30
865	45	341	2026-10-14 17:03:35.125188+05:30
866	168	341	2026-10-14 17:03:35.125191+05:30
878	45	346	2026-10-14 17:03:35.230661+05:30
879	163	346	2026-10-14 17:03:35.230665+05:30
889	45	351	2026-10-14 17:03:35.336801+05:30
890	175	351	2026-10-14 17:03:35.336805+05:30
899	45	356	2026-10-14 17:03:35.439813+05:30
900	168	356	2026-10-14 17:03:35.439817+05:30
901	163	356	2026-10-14 17:03:35.439817+05:30
913	45	361	2026-10-14 17:03:35.543935+05:30
914	176	361	2026-10-14 17:03:35.543939+05:30
925	45	366	2026-10-14 17:03:35.642432+05:30
926	165	366	2026-10-14 17:03:35.642435+05:30
935	45	371	2026-10-14 17:03:35.736979+05:30
936	168	371	2026-10-14 17:03:35.736982+05:30
946	45	376	2026-10-14 17:03:35.834986+05:30
947	172	376	2026-10-14 17:03:35.834989+05:30
957	45	381	2026-10-14 17:03:35.932046+05:30
958	175	381	2026-10-14 17:03:35.93205+05:30
959	177	381	2026-10-14 17:03:35.93205+05:30
970	45	386	2026-10-14 17:03:36.031344+05:30
971	177	386	2026-10-14 17:03:36.031347+05:30
981	45	391	2026-10-14 17:03:36.128276+05:30
982	168	391	2026-10-14 17:03:36.128281+05:30
983	175	391	2026-10-14 17:03:36.128282+05:30
992	45	396	2026-10-14 17:03:36.223846+05:30
993	163	396	2026-10-14 17:03:36.223849+05:30
1004	45	401	2026-10-14 17:03:36.321067+05:30
1005	175	401	2026-10-14 17:03:36.32107+05:30
1014	45	406	2026-10-14 17:03:36.414907+05:30
1015	172	406	2026-10-14 17:03:36.41491+05:30
1025	45	411	2026-10-14 17:03:36.513166+05:30
1026	168	411	2026-10-14 17:03:36.51317+05:30
1027	177	411	2026-10-14 17:03:36.513171+05:30
1039	45	416	2026-10-14 17:03:36.60811+05:30
1040	177	416	2026-10-14 17:03:36.608114+05:30
1041	175	416	2026-10-14 17:03:36.608115+05:30
1052	45	421	2026-10-14 17:03:36.705972+05:30
1053	163	421	2026-10-14 17:03:36.705975+05:30
1066	45	426	2026-10-14 17:03:36.801124+05:30
1067	163	426	2026-10-14 17:03:36.801127+05:30
1076	45	431	2026-10-14 17:03:36.89418+05:30
1077	174	431	2026-10-14 17:03:36.894183+05:30
1089	45	436	2026-10-14 17:03:36.991564+05:30
1090	169	436	2026-10-14 17:03:36.991568+05:30
1101	45	441	2026-10-14 17:03:37.085503+05:30
1102	175	441	2026-10-14 17:03:37.085507+05:30
1112	45	446	2026-10-14 17:03:37.177538+05:30
1113	175	446	2026-10-14 17:03:37.177541+05:30
1114	177	446	2026-10-14 17:03:37.177542+05:30
1123	45	451	2026-10-14 17:03:37.272297+05:30
1124	177	451	2026-10-14 17:03:37.272303+05:30
1125	165	451	2026-10-14 17:03:37.272304+05:30
1136	45	456	2026-10-14 17:03:37.368996+05:30
1137	172	456	2026-10-14 17:03:37.369+05:30
1138	166	456	2026-10-14 17:03:37.369+05:30
1150	45	461	2026-10-14 17:03:37.465424+05:30
1151	175	461	2026-10-14 17:03:37.465428+05:30
1160	45	466	2026-10-14 17:03:37.557662+05:30
1161	169	466	2026-10-14 17:03:37.557666+05:30
1162	168	466	2026-10-14 17:03:37.557667+05:30
1172	45	471	2026-10-14 17:03:37.653305+05:30
1173	175	471	2026-10-14 17:03:37.653308+05:30
1184	45	476	2026-10-14 17:03:37.748918+05:30
1185	168	476	2026-10-14 17:03:37.748922+05:30
1186	177	476	2026-10-14 17:03:37.748923+05:30
1200	45	481	2026-10-14 17:03:37.846487+05:30
1201	168	481	2026-10-14 17:03:37.846491+05:30
1202	163	481	2026-10-14 17:03:37.846491+05:30
1213	45	486	2026-10-14 17:03:37.979877+05:30
1214	177	486	2026-10-14 17:03:37.979881+05:30
1226	45	491	2026-10-14 17:03:38.085033+05:30
1227	177	491	2026-10-14 17:03:38.085036+05:30
1228	165	491	2026-10-14 17:03:38.085037+05:30
1237	45	496	2026-10-14 17:03:38.186321+05:30
1238	176	496	2026-10-14 17:03:38.186325+05:30
1247	45	501	2026-10-14 17:03:38.280113+05:30
1248	168	501	2026-10-14 17:03:38.280116+05:30
1260	45	506	2026-10-14 17:03:38.378+05:30
1261	177	506	2026-10-14 17:03:38.378004+05:30
1270	45	511	2026-10-14 17:03:38.474511+05:30
1271	177	511	2026-10-14 17:03:38.474515+05:30
1282	45	516	2026-10-14 17:03:38.571403+05:30
1283	175	516	2026-10-14 17:03:38.571407+05:30
1294	45	521	2026-10-14 17:03:38.70025+05:30
1295	168	521	2026-10-14 17:03:38.700254+05:30
1306	45	526	2026-10-14 17:03:38.798826+05:30
1307	176	526	2026-10-14 17:03:38.79883+05:30
1316	45	531	2026-10-14 17:03:38.898198+05:30
1317	177	531	2026-10-14 17:03:38.898202+05:30
1325	45	536	2026-10-14 17:03:38.99357+05:30
1326	163	536	2026-10-14 17:03:38.993574+05:30
1336	45	541	2026-10-14 17:03:39.090182+05:30
1337	166	541	2026-10-14 17:03:39.090186+05:30
1338	177	541	2026-10-14 17:03:39.090187+05:30
1349	45	546	2026-10-14 17:03:39.19897+05:30
1350	168	546	2026-10-14 17:03:39.198973+05:30
1361	45	551	2026-10-14 17:03:39.294572+05:30
1362	177	551	2026-10-14 17:03:39.294575+05:30
1372	46	556	2026-10-14 17:03:39.390433+05:30
1373	171	556	2026-10-14 17:03:39.390437+05:30
1374	172	556	2026-10-14 17:03:39.390438+05:30
1375	175	556	2026-10-14 17:03:39.390439+05:30
1376	177	556	2026-10-14 17:03:39.39044+05:30
1387	48	561	2026-10-14 17:03:39.48228+05:30
1388	163	561	2026-10-14 17:03:39.482283+05:30
719	45	282	2026-10-14 17:03:33.972105+05:30
720	176	282	2026-10-14 17:03:33.972108+05:30
730	45	287	2026-10-14 17:03:34.069034+05:30
731	177	287	2026-10-14 17:03:34.069038+05:30
743	45	292	2026-10-14 17:03:34.170849+05:30
744	172	292	2026-10-14 17:03:34.170852+05:30
755	45	297	2026-10-14 17:03:34.267656+05:30
756	172	297	2026-10-14 17:03:34.267659+05:30
766	45	302	2026-10-14 17:03:34.36557+05:30
767	177	302	2026-10-14 17:03:34.365573+05:30
768	163	302	2026-10-14 17:03:34.365574+05:30
778	45	307	2026-10-14 17:03:34.463361+05:30
779	177	307	2026-10-14 17:03:34.463365+05:30
780	163	307	2026-10-14 17:03:34.463366+05:30
792	45	312	2026-10-14 17:03:34.557544+05:30
793	175	312	2026-10-14 17:03:34.557548+05:30
794	177	312	2026-10-14 17:03:34.557548+05:30
804	45	317	2026-10-14 17:03:34.65232+05:30
805	177	317	2026-10-14 17:03:34.652324+05:30
806	165	317	2026-10-14 17:03:34.652325+05:30
819	45	322	2026-10-14 17:03:34.747239+05:30
820	165	322	2026-10-14 17:03:34.747243+05:30
821	177	322	2026-10-14 17:03:34.747244+05:30
832	45	327	2026-10-14 17:03:34.843305+05:30
833	172	327	2026-10-14 17:03:34.843308+05:30
844	45	332	2026-10-14 17:03:34.940633+05:30
845	169	332	2026-10-14 17:03:34.940637+05:30
846	175	332	2026-10-14 17:03:34.940637+05:30
856	45	337	2026-10-14 17:03:35.042436+05:30
857	168	337	2026-10-14 17:03:35.042439+05:30
867	45	342	2026-10-14 17:03:35.145484+05:30
868	168	342	2026-10-14 17:03:35.145489+05:30
869	175	342	2026-10-14 17:03:35.145491+05:30
880	45	347	2026-10-14 17:03:35.250389+05:30
881	175	347	2026-10-14 17:03:35.250393+05:30
882	177	347	2026-10-14 17:03:35.250394+05:30
891	45	352	2026-10-14 17:03:35.356847+05:30
892	177	352	2026-10-14 17:03:35.356851+05:30
902	45	357	2026-10-14 17:03:35.459724+05:30
903	172	357	2026-10-14 17:03:35.459728+05:30
904	175	357	2026-10-14 17:03:35.459729+05:30
905	177	357	2026-10-14 17:03:35.45973+05:30
915	45	362	2026-10-14 17:03:35.563856+05:30
916	176	362	2026-10-14 17:03:35.563859+05:30
927	45	367	2026-10-14 17:03:35.662881+05:30
928	172	367	2026-10-14 17:03:35.662884+05:30
937	45	372	2026-10-14 17:03:35.756261+05:30
938	163	372	2026-10-14 17:03:35.756265+05:30
948	45	377	2026-10-14 17:03:35.85323+05:30
949	172	377	2026-10-14 17:03:35.853234+05:30
960	45	382	2026-10-14 17:03:35.952161+05:30
961	175	382	2026-10-14 17:03:35.952165+05:30
962	177	382	2026-10-14 17:03:35.952166+05:30
972	45	387	2026-10-14 17:03:36.051537+05:30
973	177	387	2026-10-14 17:03:36.05154+05:30
984	45	392	2026-10-14 17:03:36.148004+05:30
985	178	392	2026-10-14 17:03:36.148007+05:30
994	45	397	2026-10-14 17:03:36.244144+05:30
995	168	397	2026-10-14 17:03:36.244147+05:30
996	175	397	2026-10-14 17:03:36.244148+05:30
1006	45	402	2026-10-14 17:03:36.340347+05:30
1007	166	402	2026-10-14 17:03:36.340351+05:30
1016	45	407	2026-10-14 17:03:36.432773+05:30
1017	168	407	2026-10-14 17:03:36.432776+05:30
1028	45	412	2026-10-14 17:03:36.531962+05:30
1029	168	412	2026-10-14 17:03:36.531965+05:30
1042	45	417	2026-10-14 17:03:36.629669+05:30
1043	177	417	2026-10-14 17:03:36.629673+05:30
1054	45	422	2026-10-14 17:03:36.724272+05:30
1055	167	422	2026-10-14 17:03:36.724277+05:30
1056	174	422	2026-10-14 17:03:36.724278+05:30
1057	163	422	2026-10-14 17:03:36.72428+05:30
1068	45	427	2026-10-14 17:03:36.819093+05:30
1069	175	427	2026-10-14 17:03:36.819096+05:30
1078	45	432	2026-10-14 17:03:36.915443+05:30
1079	174	432	2026-10-14 17:03:36.915447+05:30
1091	45	437	2026-10-14 17:03:37.010775+05:30
1092	175	437	2026-10-14 17:03:37.010778+05:30
1093	177	437	2026-10-14 17:03:37.010779+05:30
1103	45	442	2026-10-14 17:03:37.10394+05:30
1104	166	442	2026-10-14 17:03:37.103943+05:30
1115	45	447	2026-10-14 17:03:37.196618+05:30
1116	177	447	2026-10-14 17:03:37.196621+05:30
1126	45	452	2026-10-14 17:03:37.291474+05:30
1127	169	452	2026-10-14 17:03:37.291478+05:30
1128	168	452	2026-10-14 17:03:37.291479+05:30
1139	45	457	2026-10-14 17:03:37.387272+05:30
1140	165	457	2026-10-14 17:03:37.387275+05:30
1141	177	457	2026-10-14 17:03:37.387276+05:30
1152	45	462	2026-10-14 17:03:37.484574+05:30
1153	177	462	2026-10-14 17:03:37.484577+05:30
1163	45	467	2026-10-14 17:03:37.577295+05:30
1164	175	467	2026-10-14 17:03:37.577299+05:30
1165	177	467	2026-10-14 17:03:37.5773+05:30
1174	45	472	2026-10-14 17:03:37.671006+05:30
1175	168	472	2026-10-14 17:03:37.671009+05:30
1187	45	477	2026-10-14 17:03:37.769908+05:30
1188	165	477	2026-10-14 17:03:37.769912+05:30
1189	177	477	2026-10-14 17:03:37.769912+05:30
1203	45	482	2026-10-14 17:03:37.86595+05:30
1204	175	482	2026-10-14 17:03:37.865954+05:30
1215	45	487	2026-10-14 17:03:38.000738+05:30
1216	177	487	2026-10-14 17:03:38.000741+05:30
1217	165	487	2026-10-14 17:03:38.000742+05:30
1229	45	492	2026-10-14 17:03:38.104965+05:30
1230	177	492	2026-10-14 17:03:38.104969+05:30
1239	45	497	2026-10-14 17:03:38.206267+05:30
1240	175	497	2026-10-14 17:03:38.20627+05:30
1249	45	502	2026-10-14 17:03:38.299736+05:30
1250	169	502	2026-10-14 17:03:38.299739+05:30
1251	176	502	2026-10-14 17:03:38.29974+05:30
1262	45	507	2026-10-14 17:03:38.396596+05:30
1263	177	507	2026-10-14 17:03:38.3966+05:30
1272	45	512	2026-10-14 17:03:38.494523+05:30
1273	177	512	2026-10-14 17:03:38.494528+05:30
1274	175	512	2026-10-14 17:03:38.494529+05:30
1284	45	517	2026-10-14 17:03:38.612546+05:30
1285	165	517	2026-10-14 17:03:38.61255+05:30
1286	166	517	2026-10-14 17:03:38.612552+05:30
1296	45	522	2026-10-14 17:03:38.718838+05:30
1297	168	522	2026-10-14 17:03:38.718841+05:30
1308	45	527	2026-10-14 17:03:38.819483+05:30
1309	177	527	2026-10-14 17:03:38.819487+05:30
1318	45	532	2026-10-14 17:03:38.917786+05:30
1327	45	537	2026-10-14 17:03:39.012311+05:30
1328	175	537	2026-10-14 17:03:39.012315+05:30
1339	45	542	2026-10-14 17:03:39.108827+05:30
1340	177	542	2026-10-14 17:03:39.108831+05:30
1341	168	542	2026-10-14 17:03:39.108832+05:30
1351	45	547	2026-10-14 17:03:39.218417+05:30
1352	177	547	2026-10-14 17:03:39.218421+05:30
1363	45	552	2026-10-14 17:03:39.312887+05:30
1364	171	552	2026-10-14 17:03:39.312891+05:30
1377	46	557	2026-10-14 17:03:39.409658+05:30
1378	176	557	2026-10-14 17:03:39.409663+05:30
1379	171	557	2026-10-14 17:03:39.409664+05:30
1389	48	562	2026-10-14 17:03:39.503075+05:30
1390	168	562	2026-10-14 17:03:39.503079+05:30
1391	171	562	2026-10-14 17:03:39.503079+05:30
721	45	283	2026-10-14 17:03:33.992323+05:30
722	175	283	2026-10-14 17:03:33.992326+05:30
732	45	288	2026-10-14 17:03:34.087998+05:30
733	163	288	2026-10-14 17:03:34.088002+05:30
734	167	288	2026-10-14 17:03:34.088003+05:30
745	45	293	2026-10-14 17:03:34.189442+05:30
746	175	293	2026-10-14 17:03:34.189445+05:30
757	45	298	2026-10-14 17:03:34.286171+05:30
758	163	298	2026-10-14 17:03:34.286174+05:30
769	45	303	2026-10-14 17:03:34.386032+05:30
770	177	303	2026-10-14 17:03:34.386035+05:30
781	45	308	2026-10-14 17:03:34.48267+05:30
782	177	308	2026-10-14 17:03:34.482674+05:30
795	45	313	2026-10-14 17:03:34.577415+05:30
796	177	313	2026-10-14 17:03:34.577419+05:30
807	45	318	2026-10-14 17:03:34.671046+05:30
808	177	318	2026-10-14 17:03:34.671049+05:30
809	175	318	2026-10-14 17:03:34.67105+05:30
822	45	323	2026-10-14 17:03:34.765207+05:30
823	163	323	2026-10-14 17:03:34.76521+05:30
834	45	328	2026-10-14 17:03:34.861767+05:30
835	167	328	2026-10-14 17:03:34.861775+05:30
836	169	328	2026-10-14 17:03:34.861776+05:30
847	45	333	2026-10-14 17:03:34.960469+05:30
848	176	333	2026-10-14 17:03:34.960472+05:30
849	168	333	2026-10-14 17:03:34.960473+05:30
858	45	338	2026-10-14 17:03:35.063699+05:30
859	164	338	2026-10-14 17:03:35.063703+05:30
870	45	343	2026-10-14 17:03:35.165148+05:30
871	177	343	2026-10-14 17:03:35.165151+05:30
872	165	343	2026-10-14 17:03:35.165152+05:30
883	45	348	2026-10-14 17:03:35.272576+05:30
884	168	348	2026-10-14 17:03:35.27258+05:30
893	45	353	2026-10-14 17:03:35.377339+05:30
894	168	353	2026-10-14 17:03:35.377343+05:30
906	45	358	2026-10-14 17:03:35.480905+05:30
907	172	358	2026-10-14 17:03:35.480909+05:30
908	168	358	2026-10-14 17:03:35.48091+05:30
917	45	363	2026-10-14 17:03:35.583277+05:30
918	168	363	2026-10-14 17:03:35.58328+05:30
929	45	368	2026-10-14 17:03:35.681271+05:30
930	177	368	2026-10-14 17:03:35.681274+05:30
939	45	373	2026-10-14 17:03:35.774034+05:30
940	168	373	2026-10-14 17:03:35.774038+05:30
941	175	373	2026-10-14 17:03:35.774039+05:30
950	45	378	2026-10-14 17:03:35.872516+05:30
951	163	378	2026-10-14 17:03:35.872519+05:30
952	175	378	2026-10-14 17:03:35.87252+05:30
963	45	383	2026-10-14 17:03:35.970811+05:30
964	166	383	2026-10-14 17:03:35.970814+05:30
974	45	388	2026-10-14 17:03:36.070303+05:30
975	177	388	2026-10-14 17:03:36.070306+05:30
986	45	393	2026-10-14 17:03:36.168025+05:30
987	163	393	2026-10-14 17:03:36.168028+05:30
997	45	398	2026-10-14 17:03:36.263517+05:30
998	177	398	2026-10-14 17:03:36.263521+05:30
1008	45	403	2026-10-14 17:03:36.358333+05:30
1009	176	403	2026-10-14 17:03:36.358337+05:30
1018	45	408	2026-10-14 17:03:36.453809+05:30
1019	172	408	2026-10-14 17:03:36.453813+05:30
1020	175	408	2026-10-14 17:03:36.453813+05:30
1030	45	413	2026-10-14 17:03:36.551935+05:30
1031	168	413	2026-10-14 17:03:36.551939+05:30
1032	163	413	2026-10-14 17:03:36.55194+05:30
1033	175	413	2026-10-14 17:03:36.55194+05:30
1044	45	418	2026-10-14 17:03:36.648849+05:30
1045	168	418	2026-10-14 17:03:36.648853+05:30
1046	165	418	2026-10-14 17:03:36.648854+05:30
1058	45	423	2026-10-14 17:03:36.745135+05:30
1059	177	423	2026-10-14 17:03:36.745139+05:30
1070	45	428	2026-10-14 17:03:36.838283+05:30
1071	175	428	2026-10-14 17:03:36.838287+05:30
1080	45	433	2026-10-14 17:03:36.933468+05:30
1081	174	433	2026-10-14 17:03:36.933471+05:30
1082	163	433	2026-10-14 17:03:36.933472+05:30
1094	45	438	2026-10-14 17:03:37.029299+05:30
1095	169	438	2026-10-14 17:03:37.029302+05:30
1105	45	443	2026-10-14 17:03:37.122748+05:30
1106	175	443	2026-10-14 17:03:37.122751+05:30
1117	45	448	2026-10-14 17:03:37.215853+05:30
1118	175	448	2026-10-14 17:03:37.215857+05:30
1129	45	453	2026-10-14 17:03:37.309326+05:30
1130	175	453	2026-10-14 17:03:37.30933+05:30
1131	177	453	2026-10-14 17:03:37.30933+05:30
1142	45	458	2026-10-14 17:03:37.40751+05:30
1143	177	458	2026-10-14 17:03:37.407514+05:30
1154	45	463	2026-10-14 17:03:37.502193+05:30
1155	177	463	2026-10-14 17:03:37.502196+05:30
1166	45	468	2026-10-14 17:03:37.597257+05:30
1167	172	468	2026-10-14 17:03:37.59726+05:30
1176	45	473	2026-10-14 17:03:37.690508+05:30
1177	167	473	2026-10-14 17:03:37.690511+05:30
1190	45	478	2026-10-14 17:03:37.788889+05:30
1191	175	478	2026-10-14 17:03:37.788892+05:30
1192	177	478	2026-10-14 17:03:37.788893+05:30
1205	45	483	2026-10-14 17:03:37.883922+05:30
1206	165	483	2026-10-14 17:03:37.883926+05:30
1218	45	488	2026-10-14 17:03:38.022133+05:30
1219	175	488	2026-10-14 17:03:38.022136+05:30
1231	45	493	2026-10-14 17:03:38.125115+05:30
1232	177	493	2026-10-14 17:03:38.125163+05:30
1241	45	498	2026-10-14 17:03:38.223366+05:30
1252	45	503	2026-10-14 17:03:38.319228+05:30
1253	172	503	2026-10-14 17:03:38.319231+05:30
1254	166	503	2026-10-14 17:03:38.319232+05:30
1264	45	508	2026-10-14 17:03:38.416036+05:30
1265	177	508	2026-10-14 17:03:38.416039+05:30
1275	45	513	2026-10-14 17:03:38.515582+05:30
1276	163	513	2026-10-14 17:03:38.515585+05:30
1287	45	518	2026-10-14 17:03:38.638748+05:30
1288	177	518	2026-10-14 17:03:38.638752+05:30
1298	45	523	2026-10-14 17:03:38.737748+05:30
1299	163	523	2026-10-14 17:03:38.737752+05:30
1300	165	523	2026-10-14 17:03:38.737753+05:30
1310	45	528	2026-10-14 17:03:38.838615+05:30
1311	175	528	2026-10-14 17:03:38.838618+05:30
1319	45	533	2026-10-14 17:03:38.936362+05:30
1320	177	533	2026-10-14 17:03:38.936367+05:30
1329	45	538	2026-10-14 17:03:39.032733+05:30
1330	172	538	2026-10-14 17:03:39.032736+05:30
1342	45	543	2026-10-14 17:03:39.128408+05:30
1343	163	543	2026-10-14 17:03:39.128412+05:30
1344	172	543	2026-10-14 17:03:39.128413+05:30
1353	45	548	2026-10-14 17:03:39.236802+05:30
1354	177	548	2026-10-14 17:03:39.236805+05:30
1365	45	553	2026-10-14 17:03:39.330058+05:30
1366	168	553	2026-10-14 17:03:39.330061+05:30
1380	46	558	2026-10-14 17:03:39.429914+05:30
1381	176	558	2026-10-14 17:03:39.429918+05:30
1382	171	558	2026-10-14 17:03:39.429918+05:30
1392	48	563	2026-10-14 17:03:39.522854+05:30
1393	165	563	2026-10-14 17:03:39.522858+05:30
1394	169	563	2026-10-14 17:03:39.522858+05:30
1395	166	563	2026-10-14 17:03:39.522859+05:30
723	45	284	2026-10-14 17:03:34.012091+05:30
724	177	284	2026-10-14 17:03:34.012095+05:30
735	45	289	2026-10-14 17:03:34.107654+05:30
736	175	289	2026-10-14 17:03:34.107657+05:30
747	45	294	2026-10-14 17:03:34.208797+05:30
748	169	294	2026-10-14 17:03:34.208801+05:30
759	45	299	2026-10-14 17:03:34.305608+05:30
760	163	299	2026-10-14 17:03:34.305612+05:30
771	45	304	2026-10-14 17:03:34.404031+05:30
772	172	304	2026-10-14 17:03:34.404035+05:30
783	45	309	2026-10-14 17:03:34.502418+05:30
784	175	309	2026-10-14 17:03:34.502421+05:30
785	177	309	2026-10-14 17:03:34.502422+05:30
797	45	314	2026-10-14 17:03:34.597347+05:30
798	175	314	2026-10-14 17:03:34.59735+05:30
810	45	319	2026-10-14 17:03:34.689159+05:30
811	177	319	2026-10-14 17:03:34.689163+05:30
812	175	319	2026-10-14 17:03:34.689163+05:30
824	45	324	2026-10-14 17:03:34.783226+05:30
825	163	324	2026-10-14 17:03:34.783232+05:30
837	45	329	2026-10-14 17:03:34.881845+05:30
838	176	329	2026-10-14 17:03:34.881849+05:30
850	45	334	2026-10-14 17:03:34.980787+05:30
851	163	334	2026-10-14 17:03:34.98079+05:30
860	45	339	2026-10-14 17:03:35.08604+05:30
861	177	339	2026-10-14 17:03:35.086044+05:30
873	45	344	2026-10-14 17:03:35.187311+05:30
874	175	344	2026-10-14 17:03:35.187315+05:30
885	45	349	2026-10-14 17:03:35.292667+05:30
886	163	349	2026-10-14 17:03:35.29267+05:30
895	45	354	2026-10-14 17:03:35.398386+05:30
896	163	354	2026-10-14 17:03:35.398389+05:30
909	45	359	2026-10-14 17:03:35.501715+05:30
910	167	359	2026-10-14 17:03:35.501719+05:30
919	45	364	2026-10-14 17:03:35.601406+05:30
920	175	364	2026-10-14 17:03:35.601409+05:30
921	177	364	2026-10-14 17:03:35.60141+05:30
931	45	369	2026-10-14 17:03:35.700927+05:30
932	177	369	2026-10-14 17:03:35.700931+05:30
942	45	374	2026-10-14 17:03:35.794237+05:30
943	177	374	2026-10-14 17:03:35.794241+05:30
953	45	379	2026-10-14 17:03:35.891204+05:30
954	168	379	2026-10-14 17:03:35.891208+05:30
965	45	384	2026-10-14 17:03:35.990152+05:30
966	175	384	2026-10-14 17:03:35.990156+05:30
976	45	389	2026-10-14 17:03:36.08987+05:30
977	172	389	2026-10-14 17:03:36.089873+05:30
978	169	389	2026-10-14 17:03:36.089874+05:30
988	45	394	2026-10-14 17:03:36.186257+05:30
989	177	394	2026-10-14 17:03:36.186261+05:30
999	45	399	2026-10-14 17:03:36.282897+05:30
1000	163	399	2026-10-14 17:03:36.2829+05:30
1001	172	399	2026-10-14 17:03:36.282901+05:30
1010	45	404	2026-10-14 17:03:36.377594+05:30
1011	169	404	2026-10-14 17:03:36.377599+05:30
1021	45	409	2026-10-14 17:03:36.472414+05:30
1022	165	409	2026-10-14 17:03:36.472417+05:30
1034	45	414	2026-10-14 17:03:36.570219+05:30
1035	168	414	2026-10-14 17:03:36.570222+05:30
1047	45	419	2026-10-14 17:03:36.668671+05:30
1048	177	419	2026-10-14 17:03:36.668674+05:30
1049	165	419	2026-10-14 17:03:36.668675+05:30
1060	45	424	2026-10-14 17:03:36.764261+05:30
1061	177	424	2026-10-14 17:03:36.764265+05:30
1062	175	424	2026-10-14 17:03:36.764266+05:30
1063	166	424	2026-10-14 17:03:36.764266+05:30
1072	45	429	2026-10-14 17:03:36.856836+05:30
1073	177	429	2026-10-14 17:03:36.85684+05:30
1083	45	434	2026-10-14 17:03:36.952805+05:30
1084	172	434	2026-10-14 17:03:36.952808+05:30
1085	175	434	2026-10-14 17:03:36.952809+05:30
1096	45	439	2026-10-14 17:03:37.048388+05:30
1097	175	439	2026-10-14 17:03:37.048392+05:30
1098	177	439	2026-10-14 17:03:37.048393+05:30
1107	45	444	2026-10-14 17:03:37.140275+05:30
1108	175	444	2026-10-14 17:03:37.140279+05:30
1119	45	449	2026-10-14 17:03:37.235903+05:30
1120	177	449	2026-10-14 17:03:37.235906+05:30
1132	45	454	2026-10-14 17:03:37.328357+05:30
1133	165	454	2026-10-14 17:03:37.328361+05:30
1144	45	459	2026-10-14 17:03:37.425183+05:30
1145	177	459	2026-10-14 17:03:37.425187+05:30
1146	165	459	2026-10-14 17:03:37.425188+05:30
1156	45	464	2026-10-14 17:03:37.520148+05:30
1157	165	464	2026-10-14 17:03:37.520151+05:30
1168	45	469	2026-10-14 17:03:37.616103+05:30
1169	177	469	2026-10-14 17:03:37.616107+05:30
1178	45	474	2026-10-14 17:03:37.709839+05:30
1179	163	474	2026-10-14 17:03:37.709842+05:30
1193	45	479	2026-10-14 17:03:37.808021+05:30
1194	174	479	2026-10-14 17:03:37.808025+05:30
1195	172	479	2026-10-14 17:03:37.808026+05:30
1196	177	479	2026-10-14 17:03:37.808027+05:30
1207	45	484	2026-10-14 17:03:37.906011+05:30
1208	165	484	2026-10-14 17:03:37.906015+05:30
1209	168	484	2026-10-14 17:03:37.906017+05:30
1220	45	489	2026-10-14 17:03:38.041993+05:30
1221	168	489	2026-10-14 17:03:38.041996+05:30
1222	172	489	2026-10-14 17:03:38.041997+05:30
1223	163	489	2026-10-14 17:03:38.041998+05:30
1233	45	494	2026-10-14 17:03:38.144317+05:30
1234	163	494	2026-10-14 17:03:38.14432+05:30
1242	45	499	2026-10-14 17:03:38.241105+05:30
1243	175	499	2026-10-14 17:03:38.241108+05:30
1244	177	499	2026-10-14 17:03:38.241109+05:30
1255	45	504	2026-10-14 17:03:38.33987+05:30
1256	172	504	2026-10-14 17:03:38.339878+05:30
1257	177	504	2026-10-14 17:03:38.339879+05:30
1266	45	509	2026-10-14 17:03:38.43662+05:30
1267	176	509	2026-10-14 17:03:38.436624+05:30
1277	45	514	2026-10-14 17:03:38.535232+05:30
1278	167	514	2026-10-14 17:03:38.535235+05:30
1289	45	519	2026-10-14 17:03:38.660777+05:30
1290	177	519	2026-10-14 17:03:38.660781+05:30
1301	45	524	2026-10-14 17:03:38.756477+05:30
1302	163	524	2026-10-14 17:03:38.756481+05:30
1312	45	529	2026-10-14 17:03:38.858839+05:30
1313	177	529	2026-10-14 17:03:38.858843+05:30
1321	45	534	2026-10-14 17:03:38.956347+05:30
1322	165	534	2026-10-14 17:03:38.956351+05:30
1331	45	539	2026-10-14 17:03:39.052446+05:30
1332	172	539	2026-10-14 17:03:39.05245+05:30
1333	177	539	2026-10-14 17:03:39.05245+05:30
1345	45	544	2026-10-14 17:03:39.148707+05:30
1346	169	544	2026-10-14 17:03:39.148711+05:30
1355	45	549	2026-10-14 17:03:39.255758+05:30
1356	169	549	2026-10-14 17:03:39.255762+05:30
1357	165	549	2026-10-14 17:03:39.255763+05:30
1367	46	554	2026-10-14 17:03:39.349476+05:30
1368	175	554	2026-10-14 17:03:39.349479+05:30
1369	165	554	2026-10-14 17:03:39.34948+05:30
1383	47	559	2026-10-14 17:03:39.446446+05:30
1396	48	564	2026-10-14 17:03:39.542047+05:30
1397	165	564	2026-10-14 17:03:39.54205+05:30
1398	169	564	2026-10-14 17:03:39.542051+05:30
1399	171	564	2026-10-14 17:03:39.542052+05:30
\.


--
-- Data for Name: site_figures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.site_figures (id, account_id, start_date, end_date, site_figure, calculated_by, calculated_at) FROM stdin;
\.


--
-- Name: account_websites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_websites_id_seq', 564, true);


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounts_id_seq', 564, true);


--
-- Name: figures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.figures_id_seq', 2, true);


--
-- Name: parties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.parties_id_seq', 180, true);


--
-- Name: party_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.party_accounts_id_seq', 1399, true);


--
-- Name: site_figures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.site_figures_id_seq', 1, false);


--
-- Name: account_websites account_websites_account_id_website_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_websites
    ADD CONSTRAINT account_websites_account_id_website_key UNIQUE (account_id, website);


--
-- Name: account_websites account_websites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_websites
    ADD CONSTRAINT account_websites_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: admin_credentials admin_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_credentials
    ADD CONSTRAINT admin_credentials_pkey PRIMARY KEY (id);


--
-- Name: admin_credentials admin_credentials_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_credentials
    ADD CONSTRAINT admin_credentials_username_key UNIQUE (username);


--
-- Name: figures figures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT figures_pkey PRIMARY KEY (id);


--
-- Name: parties parties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parties
    ADD CONSTRAINT parties_pkey PRIMARY KEY (id);


--
-- Name: party_accounts party_accounts_party_id_account_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.party_accounts
    ADD CONSTRAINT party_accounts_party_id_account_id_key UNIQUE (party_id, account_id);


--
-- Name: party_accounts party_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.party_accounts
    ADD CONSTRAINT party_accounts_pkey PRIMARY KEY (id);


--
-- Name: site_figures site_figures_account_id_start_date_end_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_figures
    ADD CONSTRAINT site_figures_account_id_start_date_end_date_key UNIQUE (account_id, start_date, end_date);


--
-- Name: site_figures site_figures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_figures
    ADD CONSTRAINT site_figures_pkey PRIMARY KEY (id);


--
-- Name: ix_account_websites_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_account_websites_account_id ON public.account_websites USING btree (account_id);


--
-- Name: ix_account_websites_website; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_account_websites_website ON public.account_websites USING btree (website);


--
-- Name: ix_figures_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_figures_account_id ON public.figures USING btree (account_id);


--
-- Name: ix_figures_figure_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_figures_figure_date ON public.figures USING btree (figure_date);


--
-- Name: ix_figures_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_figures_lookup ON public.figures USING btree (party_id, account_id, start_date, end_date);


--
-- Name: ix_figures_party_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_figures_party_id ON public.figures USING btree (party_id);


--
-- Name: ix_figures_start_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_figures_start_date ON public.figures USING btree (start_date);


--
-- Name: ix_parties_kind; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_parties_kind ON public.parties USING btree (kind);


--
-- Name: ix_parties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_parties_name_key ON public.parties USING btree (name_key);


--
-- Name: ix_party_accounts_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_party_accounts_account_id ON public.party_accounts USING btree (account_id);


--
-- Name: ix_party_accounts_party_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_party_accounts_party_id ON public.party_accounts USING btree (party_id);


--
-- Name: ix_site_figures_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_site_figures_account_id ON public.site_figures USING btree (account_id);


--
-- Name: ix_site_figures_start_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_site_figures_start_date ON public.site_figures USING btree (start_date);


--
-- Name: uq_capper_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_capper_name ON public.parties USING btree (name_key) WHERE (kind = 'capper'::public.partykind);


--
-- Name: account_websites account_websites_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_websites
    ADD CONSTRAINT account_websites_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: figures figures_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT figures_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: figures figures_entered_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT figures_entered_by_fkey FOREIGN KEY (entered_by) REFERENCES public.admin_credentials(id);


--
-- Name: figures figures_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.figures
    ADD CONSTRAINT figures_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id);


--
-- Name: party_accounts party_accounts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.party_accounts
    ADD CONSTRAINT party_accounts_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: party_accounts party_accounts_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.party_accounts
    ADD CONSTRAINT party_accounts_party_id_fkey FOREIGN KEY (party_id) REFERENCES public.parties(id);


--
-- Name: site_figures site_figures_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_figures
    ADD CONSTRAINT site_figures_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: site_figures site_figures_calculated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_figures
    ADD CONSTRAINT site_figures_calculated_by_fkey FOREIGN KEY (calculated_by) REFERENCES public.admin_credentials(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict aMOpmlp4DmSPPkJK8LD0ELdzVBPfZdJafAipM4h9YhEByEBeyHgrnv9nExTcdml

