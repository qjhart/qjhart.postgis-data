DROP SCHEMA statsgo CASCADE;
CREATE SCHEMA statsgo;
SET search_path = statsgo, public, pg_catalog;

-- Statsgo Domains --
DROP TABLE IF EXISTS crop_name CASCADE;
CREATE TABLE crop_name (
 seq integer primary key,
 obsolete boolean not null,
 cropname varchar(32) unique
);

COPY crop_name (seq,obsolete,cropname) from STDIN delimiter as '|';
1|False|African stargrass
2|False|Alfalfa hay
3|False|Alfalfa pasture
4|False|Alfalfa seed
5|False|Almonds
6|False|Annual ryegrass
7|False|Apples
8|False|Apricots
9|False|Artichokes
10|False|Asparagus
11|False|Avocados
12|False|Bahiagrass
13|False|Bahiagrass hay
14|False|Bananas
15|False|Barley
16|False|Barley-fallow
17|False|Dry lima beans
18|False|Dry pinto beans
19|False|Dry beans
20|False|Snap beans
21|False|Unshelled lima beans
22|False|Beets
23|False|Bentgrass seed
24|False|Bermudagrass-clover hay
25|False|Bermudagrass-fescue hay
26|False|Big bluestem
27|False|Blackberries
28|False|Blueberries
29|False|Bluegrass
30|False|Bluegrass seed
31|False|Bluegrass-ladino
32|False|Bluegrass-ladino hay
33|False|Bluegrass-trefoil
34|False|Bluegrass-trefoil hay
35|False|Bluegrass-white clover
36|False|Bluegrass-white clover hay
37|False|Breadfruit
38|False|Broccoli
39|False|Bromegrass hay
40|False|Bromegrass-alfalfa
41|False|Bromegrass-alfalfa hay
42|False|Bromegrass-alsike
43|False|Bromegrass-alsike hay
44|False|Bromegrass-ladino
45|False|Broomcorn
46|False|Brussel sprouts
47|False|Buckwheat
48|False|Buffel grass
49|False|Cabbage
50|False|Chinese cabbage
51|False|Mustard cabbage
52|False|Canarygrass hay
53|False|Canarygrass-alsike
54|False|Canarygrass-alsike hay
55|False|Canarygrass-ladino
56|False|Canarygrass-ladino hay
57|False|Spring canola
58|False|Winter canola
59|False|Cantaloupe
60|False|Carrots
61|False|Cassava
62|False|Caucasian bluestem
63|False|Caucasian bluestem hay
64|False|Cauliflower
65|True|Causian bluegrass
66|False|Celery
67|False|Cherries
68|False|Clover seed
69|False|Coconuts
70|False|Coffee
71|False|Common bermudagrass
72|False|Common bermudagrass hay
73|False|Common ryegrass seed
74|False|Cool-season grasses
75|False|Corn
76|False|Corn silage
77|False|Sweet corn
78|False|Cotton lint
79|False|Pima cotton lint
80|False|Cowpeas
81|False|Cranberries
82|False|Crested wheatgrass
83|False|Crested wheatgrass-alfalfa hay
84|False|Crimson clover
85|False|Cucumbers
86|False|Fescue
87|False|Filberts
88|False|Fine fescue seed
89|False|Flax
90|False|Garlic
91|False|Garrisongrass
92|False|Grain sorghum
93|False|Grapefruit
94|False|Table grapes
95|False|Wine grapes
96|False|Grass hay
97|False|Grass silage
98|False|Grass seed
99|False|Grass-clover
100|False|Grass-legume hay
101|False|Grass-legume pasture
102|False|Green chop
103|False|Green needlegrass
104|False|Guinea grass
105|False|Annual hay crop
106|False|Hops
107|False|Improved bermudagrass
108|False|Improved bermudagrass hay
109|False|Indiangrass
110|False|Introduced bluestem
111|False|Johnsongrass
112|False|Kentucky bluegrass
113|False|Kincaid red clover
114|False|Kleingrass
115|False|Kobe lespedeza
116|False|Ladino clover
117|False|Legume hay
118|False|Lemons
119|False|Dry lentils
120|False|Lettuce
121|False|Limes
122|False|Loganberries
123|False|Macadamia nuts
124|False|Mangos
125|False|Merkergrass
126|False|Millet
127|False|Distillate mint
128|False|Molassesgrass
129|False|Mungbeans
130|False|Oats
131|False|Hay oats
132|False|Olives
133|False|Onions
134|False|Green onions
135|False|Oranges
136|False|Orchardgrass
137|False|Orchardgrass hay
138|False|Orchardgrass seed
139|False|Orchardgrass-alfalfa
140|False|Orchardgrass-alfalfa hay
141|False|Orchardgrass-alsike
142|False|Orchardgrass-alsike hay
143|False|Orchardgrass-ladino
144|False|Orchardgrass-ladino hay
145|False|Orchardgrass-lespedeza
146|False|Orchardgrass-lespedeza hay
147|False|Orchardgrass-red clover
148|False|Orchardgrass-red clover hay
149|False|Orchardgrass-trefoil
150|False|Orchardgrass-trefoil hay
151|False|Pangolagrass
152|False|Papaya
153|False|Paragrass
154|False|Pasture
155|False|Peaches
156|False|Peanuts
157|False|Pears
158|False|Winter pears
159|False|Canning peas
160|False|Dry peas
161|False|Green peas
162|False|Pecans
163|False|Black pepper
164|False|Peppers
165|False|Dry chili peppers
166|False|Fresh chili peppers
167|False|Green peppers
168|False|Perennial ryegrass seed
169|False|Improved permanent pasture
170|False|Unimproved permanent pasture
171|False|Pigeonpeas
172|False|Pineapple
173|False|Ratoon pineapple
174|False|Pistachios
175|False|Plantains
176|False|Plums
177|False|Irish potatoes
178|False|Prunes
179|False|Dry prunes
180|False|Pubescent wheatgrass
181|False|Pumpkins
182|False|Raisins
183|False|Raspberries
184|False|Red clover hay
185|False|Red clover seed
186|False|Reed canarygrass
187|False|Rice
188|False|Rye
189|False|Rye grazeout
190|False|Safflower
191|False|Small grains grazeout
192|False|Small grains hay
193|False|Small grains silage
194|False|Smooth bromegrass
195|False|Sorghum grazed
196|False|Sorghum hay
197|False|Sorghum silage
198|False|Soybeans
199|False|Spinach
200|False|Summer squash
201|False|Winter squash
202|False|Strawberries
203|False|Strawberry plants
204|False|Sugar beets
205|False|Sugarcane
206|False|18-month sugarcane
207|False|Ratoon sugarcane
208|False|Spring sugarcane
209|False|Sunflowers
210|False|Sweet potatoes
211|False|Switchgrass
212|False|Tall fescue
213|False|Tall fescue hay
214|False|Tall fescue seed
215|False|Tall fescue-alfalfa
216|False|Tall fescue-alfalfa hay
217|False|Tall fescue-alsike
218|False|Tall fescue-alsike hay
219|False|Tall fescue-ladino
220|False|Tall fescue-ladino hay
221|False|Tall fescue-lespedeza
222|False|Tall fescue-lespedeza hay
223|False|Tall fescue-red clover
224|False|Tall fescue-red clover hay
225|False|Tall wheatgrass
226|False|Tangelos
227|False|Tangerines
228|False|Taniers
229|False|Taro
230|False|Timothy hay
231|False|Timothy-alfalfa
232|False|Timothy-alfalfa hay
233|False|Timothy-alsike
234|False|Timothy-alsike hay
235|False|Timothy-red clover
236|False|Timothy-red clover hay
237|False|Tobacco
238|False|Burley tobacco
239|False|Dark air-cured tobacco
240|False|Fire-cured tobacco
241|False|Flue-cured tobacco
242|False|Light air-cured tobacco
243|False|Tomatoes
244|False|Trefoil hay
245|False|Trefoil-grass
246|False|Trefoil-grass hay
247|False|Walnuts
248|False|Warm season grasses
249|False|Watermelons
250|False|Weeping lovegrass
251|False|Wheat
252|False|Wheat grazeout
253|False|Wheat (October-March)
254|False|Spring wheat
255|False|Spring wheat-fallow
256|False|Winter wheat
257|False|Winter wheat-fallow
258|False|Yams
\.

DROP TABLE IF EXISTS crop_yield_units ;
CREATE TABLE crop_yield_units (
 seq integer primary key,
 obsolete boolean not null,
 yldunits varchar(32) unique,
 description varchar(255)
);

COPY crop_yield_units (seq,obsolete,yldunits,description) from STDIN delimiter as '|';
1|False|Cwt|100 pounds/acre
2|False|AUM|Animal unit months/acre
3|False|Boxes|Boxes/acre
4|False|Bu|Bushels/acre
5|False|Crates|Crates/acre
6|False|Lbs|Pounds/acre
7|False|Sacks|Sacks/acre
8|False|Thousands|Thousands/acre
9|False|Tons|Tons/acre
\.

DROP TABLE IF EXISTS wildlife_rating ;
CREATE TABLE wildlife_rating (
 seq integer primary key,
 obsolete boolean not null,
 wl varchar(9) unique
);

COPY wildlife_rating from STDIN delimiter as '|';
1|False|Very poor
2|False|Poor
3|False|Fair
4|False|Good
\.

DROP TABLE IF EXISTS capability_class ;
CREATE TABLE capability_class (
 seq integer primary key,
 obsolete boolean not null,
 capcl varchar(1) unique,
 description varchar(256)
);

COPY capability_class from STDIN delimiter as '|';
1|False|1|Soils in Class 1 have few limitations that restrict their use.
2|False|2|Soils in Class 2 have some limitations that reduce the choice of plants or require moderate conservation practices
3|False|3|Soils in Class 3 have severe limitations that reduce the choice of plants or require special conservation practices, or both.
4|False|4|Soils in Class 4 have very severe limitations that restrict the choice of plants, require very careful management, or both
5|False|5|Soils in Class 5 have little or no erosion hazard, but have other limitations impractical to remove that limit their use.
6|False|6|Soils in Class 6 have very severe limitations that make them generally unsuited to cultivation and limit their use largely to pasture, etc.
7|False|7|Soils in Class 7 have very severe limitations that make them unsuited to cultivation and that restrict their use to grazing, etc.
8|False|8|Soils (and landforms) in Class 8 have limitations that preclude their use for commercial plant production and restrict their use.
\.

DROP TABLE IF EXISTS capability_subclass ;
CREATE TABLE capability_subclass (
 seq integer primary key,
 obsolete boolean not null,
 capscl varchar(1) unique,
 description varchar(256)
);

COPY capability_subclass from STDIN delimiter as '|';
1|False|e|erosion
2|False|w|excess water
3|False|s|soil limitations within the rooting zone
4|False|c|climate condition
\.

DROP TABLE IF EXISTS component_kind ;
CREATE TABLE component_kind (
 seq integer primary key,
 obsolete boolean not null,
 compkind varchar(18) unique,
 description text
);

COPY component_kind from STDIN delimiter as '|';
1|False|Family|The component is classified and described at the family level of Soil Taxonomy.
2|False|Miscellaneous area|The component is classified and described as a non-soil area.
3|False|Series|The component is classified and described at the soil series level, the lowest level of Soil Taxonomy.
4|False|Taxadjunct|The component is described slightly outside the Soil Taxomonic limits of the name assigned. However, these differences are not significant enough to affect use and management of the soil.
5|False|Taxon above family|The component is described and classified at some level of Soil Taxonomy above the family level.
6|True|Variant|The component is described as being outside the range of the series for which it is named. The differences are great enough to warrant a new series, they do affect the use and management of the soil, but the geographical extent is considered too small to justify creating a new series.
\.


DROP TABLE IF EXISTS runoff ;
CREATE TABLE runoff (
 seq integer primary key,
 obsolete boolean not null,
 runoff varchar(10) unique
);

COPY runoff from STDIN delimiter as '|';
1|True|Ponded
2|False|Negligible
3|False|Very low
4|False|Low
5|False|Medium
6|False|High
7|False|Very high
\.

DROP TABLE IF EXISTS wind_erodibility_index ;
CREATE TABLE wind_erodibility_index (
 seq integer primary key,
 obsolete boolean not null,
 wei varchar(3) unique,
 description text
);

COPY wind_erodibility_index from STDIN delimiter as '|';
1|False|0|Soils not susceptible to wind erosion due to coarse fragments on the surface or wetness.
2|False|38|Silt, noncalcareous silty clay loam that has less than 35 percent clay content, and fibric organic soil material. Dry soil aggregates more than .84 mm are more than 50 percent by weight.
3|False|48|Noncalcareous loam and silt loam that has more than 20 percent clay content or noncalcareous clay loam that has less than 35 percent clay content. Dry soil aggregates more than .84 mm are 45 to 50 percent by weight.
4|False|56|Noncalcareous loam and silt loam that has less than 20 percent clay content or sandy clay loam, sandy clay, and hemic organic soil materials.  Dry soil aggregates more than .84 mm are 40 to 45 percent by weight.
5|False|86|Very fine sandy loam, fine sandy loam, sandy loam, coarse sandy loam, or ash material. Clay, silty clay, noncalcareous clay loam, or noncalcareous silty clay loam that has more than 35 percent clay content. Calcareous loam and silt loam or calcareous clay loam and silty clay loam. Dry soil aggregates more than .84 mm are 25 to 40 percent by weight.
6|False|134|Loamy very fine sand, loamy fine sand, loamy sand, loamy coarse sand, or sapric organic soil material. Dry soil aggregates more than .84 mm are 10 to 25 percent by weight.
7|False|160|Very fine sand, fine sand, sand, or coarse sand. Dry soil aggregates more than .84 mm are 7 to 10 percent by weight.
8|False|180|Very fine sand, fine sand, sand, or coarse sand. Dry soil aggregates more than .84 mm are 5 to 7 percent by weight.
9|False|220|Very fine sand, fine sand, sand, or coarse sand. Dry soil aggregates more than .84 mm area 3 to 5 percent by weight.
10|False|250|Very fine sand, fine sand, sand, or coarse sand. Dry soil aggregates more than .84 mm are 1 percent by weight.
11|False|310|Very fine sand, fine sand, sand, or coarse sand. Dry soil aggregates more than .84 mm are 1 percent by weight.
\.

DROP TABLE IF EXISTS wind_erodibility_group ;
CREATE TABLE wind_erodibility_group (
 seq integer primary key,
 obsolete boolean not null,
 weg varchar(2) unique,
 description text
);

COPY wind_erodibility_group from STDIN delimiter as '|';
1|False|1|Surface texture - Very fine sand, fine sand, sand or coarse sand. Percent aggregates - 1 to 7. Wind erodibility index - 160 to 310 t/a/yr, use 220 as average.
2|False|2|Surface texture - Loamy very fine sand, loamy fine sand, loamy sand, loamy coarse sand; very fine sandy loam and silt loam with 5 or less percent clay and 25 or less percent very fine sand; and sapric soil materials (as defined in Soil Taxonomy); except Folists. Percent aggregates - 10. Wind erodibility index - 134 t/a/yr.
3|False|3|Surface texture - Very fine sandy loam, fine sandy loam, sandy loam, coarse sandy loam, and noncalcareous silt loam that has 20 to 50 percent very fine sand and 5 to 12 percent clay. Percent aggregates - 25. Wind Erodibility Index - 86 t/a/yr.
4|False|4|Surface texture - Clay, silty clay, noncalcareous clay loam that has more than 35 percent clay, and noncalcareous silty clay loam that has more than 35 percent clay. All of these do not have sesquic, parasesquic, ferritic, ferruginous, or kaolinitic mineralogy (high iron oxide content).  Percent aggregates - 25. Wind erodibility index - 86 t/a/yr.
5|False|4L|Surface texture - Calcareous loam, calcareous silt loam, calcareous silt, calcareous sandy clay, calcareous sandy clay loam, calcareous clay loam and calcareous silty clay loam. Percent aggregates - 25 .Wind Erodibility Index - 86 t/a/yr.
6|False|5|Surface texture - Noncalcareous loam that has less than 20 percent clay; noncalcareous silt loam with 12 to 20 percent clay; noncalcareous sandy clay loam; noncalcareous sandy clay; and hemic materials (as defined in Soil Taxonomy). Percent aggregates - 40. Wind Erodibility Index - 56 t/a/yr.
7|False|6|Surface texture - Noncalcareous loam and silt loam that have more than 20 percent clay; noncalcareous clay loam and noncalcareous silty clay loam that has less than 35 percent clay; silt loam that has parasesquic, ferritic, or kaolinitic mineralogy (high iron oxide content). Percent aggregates - 45. Wind Erodibility Index - 48 t/a/yr.
8|False|7|Surface texture - Noncalcareous silt; noncalcareous silty clay, noncalcareous silty clay loam, and noncalcareous clay that have sesquic, parasesquic, ferritic, ferruginous, or kaolinitic mineralogy (high content of iron oxide) and are Oxisols or Ultisols; and fibric material (as defined in Soil Taxonomy). Percent aggregates - 50. Wind Erodibility Index - 48 t/a/yr.
9|False|8|Soils not susceptible to wind erosion due to rock and pararock fragments at the surface and/or wetness; and Folists
\.

DROP TABLE IF EXISTS erosion_class ;
CREATE TABLE erosion_class (
 seq integer primary key,
 obsolete boolean not null,
 erocl varchar(18) unique,
 description text
);

COPY erosion_class from STDIN delimiter as '|';
1|False|None - deposition|No apparent erosion has occurred. Deposition of soil sediment removed from other areas may have occurred.
2|False|Class 1|The soil has lost on the average <25% of the original A and/or E horizons, or of the uppermost 20 cm if the original A and/or E horizons were less than 20 cm thick. (SSM)
3|False|Class 2|The soil has lost, on the average, 25 to 75 percent of the original A and/or E horizons, or of the uppermost 20 cm if the original A and/or E horizons were less than 20 cm thick.
4|False|Class 3|The soil has lost, on the average, more than 75 percent of the original A and/or E horizon, or of the uppermost 20 cm if the original A and/or E horizons were less than 20 cm thick. (SSM)
5|False|Class 4|The soil has lost all of the original A and/or E horizons, or the uppermost 20 cm if the original A and/or E horizons were less than 20 cm thick.  Some of the orginal underlying material may have also been removed. (SSM)
\.

DROP TABLE IF EXISTS earth_cover_kind_level_one ;
CREATE TABLE earth_cover_kind_level_one (
 seq integer primary key,
 obsolete boolean not null,
 earthcovkind1 varchar(22) unique,
 description text
);

COPY earth_cover_kind_level_one from STDIN delimiter as '|';
1|False|Artificial cover|Nonvegetative cover either made or modified by human activity and prohibiting or restricting vegetative growth and water penetration.
2|False|Barren land|Nonvegetative natural cover often having a limited capacity to support vegetation - including construction sites (<5% vegetated).
3|False|Crop cover|The full cycle, including land preparation and post-harvest residue cover of annual or perennial herbaceous plants that are cultivated or harvested, or both, for the production of food, feed, oil, and fiber other than wood, and excluding hay and pasture.
4|False|Grass/herbaceous cover|Non-woody vegetative cover composed of annual or perennial grasses, grass-like plants (sedges/rushes), forbs (including alfalfa and clovers), lichens, mosses, and ferns (>75% grass, grass-like, forb cover).
5|True|Other|
6|False|Shrub cover|Vegetative cover composed of multi-stemmed and single-stemmed woody plants that attain a mature height of less than four meters (>50% shrub canopy cover).
7|False|Tree cover|Vegetative cover recognized as woody plants which usually have one perennial stem, a definitely formed crown of foliage, and a mature height of at least four meters (including ornamentals and Christmas trees) (>25% tree canopy cover).
8|False|Water cover|Earth covered by water in a fluid state. This includes seasonally frozen areas.
9|True|Wetlands|
10|True|Wetlands, drained|
\.

DROP TABLE IF EXISTS earth_cover_kind_level_two ;
CREATE TABLE earth_cover_kind_level_two (
 seq integer primary key,
 obsolete boolean not null,
 earthcovkind2 varchar(33) unique,
 description text
);

COPY earth_cover_kind_level_two from STDIN delimiter as '|';
1|False|Row crop|e.g. corn, soybeans, cotton, tomatoes and other truck crops, tulips
2|False|Close-grown crop|Wheat, rice, oats, rye, etc.
3|False|Grassland rangeland|(<10% trees, <20% shrubs) - includes rangeland used for hayland - bluestems, mixed midgrasses, shortgrass, etc.
4|False|Savanna rangeland|10 to 25% tree cover
5|False|Shrubby rangeland|(20 to 50% shrub cover) - sumac, sagebrush, mesquite
6|False|Tundra rangeland|
7|False|Tame pastureland|Fescues, bromegrass, timothy, lespedeza, etc.
8|False|Hayland|Fescues, bromegrass, timothy, alfalfa, etc.
9|False|Marshland|grass, grass-like plants
10|False|Other grass/herbaceous cover|
11|False|Crop trees|e.g. apples, pecans, date palms, citrus, ornamental nursery stock, Christmas trees
12|False|Conifers|Spruce, Douglas fur, pine, etc.
13|False|Hardwoods|Oak, hickory, elm, aspen, etc.
14|False|Intermixed conifers and hardwoods|e.g. oak-pine mix
15|False|Tropical Mangrove| royal palm, etc.
16|False|Swamp|shrubs and trees
17|False|Other tree cover|
18|False|Crop shrubs|Filbert, blueberry, and ornamentals, etc. as nursery stock
19|False|Crop vines|e.g. grapes, blackberries, raspberries
20|False|Native shrubs|e.g. creosotebush, shrub live oak, sagebrush, mesquite (including rangeland with >50% shrub cover)
21|False|Other shrub cover|e.g. kudzu, cacti, yucca
22|False|Rock|
23|False|Sand and gravel|
24|False|Culturally induced barren|saline seeps, mines, quarries, oil-waste, etc.
25|False|Permanent snow and ice|
26|False|Other barren|salt flats, slickspots, mud flats, badlands, etc.; excludes those in culturally induced earth cover
27|False|Rural transportation|Highways, railroads, etc.
28|False|Urban and built-up|Cities, towns, farmsteads, industrial sites
\.

DROP TABLE IF EXISTS drainage_class;
CREATE TABLE drainage_class (
 seq integer primary key,
 obsolete boolean not null,
 drainagecl varchar(28) unique,
 description text
);

COPY drainage_class  (seq,obsolete,drainagecl) from STDIN delimiter as '|';
1|False|Excessively drained
2|False|Somewhat excessively drained
3|False|Well drained
4|False|Moderately well drained
5|False|Somewhat poorly drained
6|False|Poorly drained
7|False|Very poorly drained
\.


DROP TABLE IF EXISTS hydric_condition ;
CREATE TABLE hydric_condition (
 seq integer primary key,
 obsolete boolean not null,
 hydricon varchar(52) unique,
 description text
);

COPY hydric_condition from STDIN delimiter as '|';
1|False|Farmable under natural conditions|Farmable under natural conditions
2|False|Neither wooded nor farmable under natural conditions|Neither wooded nor farmable under natural conditions
3|False|Wooded under natural conditions|Wooded under natural conditions.
\.

DROP TABLE IF EXISTS hydric_criteria ;
CREATE TABLE hydric_criteria (
 seq integer primary key,
 obsolete boolean not null,
 hydricri varchar(3) unique,
 description text
);

COPY hydric_criteria from STDIN delimiter as '|';
1|False|1|All Histels except Folistels, and all Histosols except Folists.
2|False|2A|Soils in Aquic suborders, great groups, or subgroups, Albolls suborder, Historthels great group, Histoturbels great group, Pachic subgroups, or Cumulic subgroups that are somewhat poorly drained with a water table equal to 0.0 foot (ft) from the surface during the growing season.
3|False|2B1|Soils in Aquic suborders, great groups, or subgroups, Albolls suborder, Historthels great group, Histoturbels great group, Pachic subgroups, or Cumulic subgroups that are poorly drained or very poorly drained and have a water table equal to 0.0 ft during the growing season if textures are coarse sand, sand, or fine sand in all layers within 20 inches.
4|False|2B2|Soils in Aquic suborders, great groups, or subgroups, Albolls suborder, Historthels great group, Histoturbels great group, Pachic subgroups, or Cumulic subgroups that are poorly drained or very poorly drained and have a water table at less than or equal to 0.5 ft from the surface during the growing season if permeability is equal to or greater than 6.0 in/hour (h) in all layers within 20 inches.
5|False|2B3|Soils in Aquic suborders, great groups, or subgroups, Albolls suborder, Historthels great group, Histoturbels great group, Pachic subgroups, or Cumulic subgroups that are poorly drained or very poorly drained and have water table* at less than or equal to 1.0 ft from the surface during the growing season if permeability is less than 6.0 in/h in any layer within 20 inches.
6|False|3|Soils that are frequently ponded for long duration or very long duration during the growing season.
7|False|4|Soils that are frequently flooded for long duration or very long duration during the growing season.
\.

DROP TABLE IF EXISTS hydric_rating ;
CREATE TABLE hydric_rating (
 seq integer primary key,
 obsolete boolean not null,
 hydricrating varchar(8) unique,
 description text
);

COPY hydric_rating from STDIN delimiter as '|';
1|False|Yes| 
2|False|No|
3|False|Unranked|
\.

DROP TABLE IF EXISTS conservation_tree_shrub_group ;
CREATE TABLE conservation_tree_shrub_group (
 seq integer primary key,
 obsolete boolean not null,
 constreeshrubgrp varchar(14) unique,
 description text
);

COPY conservation_tree_shrub_group(seq,obsolete,constreeshrubgrp) from STDIN delimiter as '|';
1|False|1
2|False|1A
3|False|1H
4|False|1K
5|False|1KK
6|False|1S
7|False|1SK
8|False|1SKK
9|False|2
10|False|2A
11|False|2H
12|False|2K
13|False|2KK
14|False|3
15|False|3A
16|False|4
17|False|4A
18|False|4C
19|False|4CA
20|False|4CC
21|False|4CK
22|False|4K
23|False|5
24|False|5A
25|False|5K
26|False|5KK
27|False|6
28|False|6A
29|False|6D
30|False|6DA
31|False|6DK
32|False|6G
33|False|6GA
34|False|6GK
35|False|6GKK
36|False|6K
37|False|6KK
38|False|7
39|False|7A
40|False|8
41|False|8K
42|False|9C
43|False|9L
44|False|9N
45|False|9NW
46|False|9W
47|False|10
48|False|Not applicable
\.

DROP TABLE IF EXISTS windbreak_suitability_group ;
CREATE TABLE windbreak_suitability_group (
 seq integer primary key,
 obsolete boolean not null,
 wndbrksuitgrp varchar(8) unique,
 description text
);

COPY windbreak_suitability_group (seq,obsolete,wndbrksuitgrp) from STDIN delimiter as '|';
1|False|1
2|False|1H
3|False|1K
4|True|1KW
5|False|1KK
6|False|2
7|False|2K
8|True|2KW
9|False|2KK
10|False|2H
11|False|3
12|False|4
13|False|4K
14|False|4C
15|False|4CK
16|False|5
17|False|5K
18|False|5KK
19|False|6
20|False|6K
21|False|6KK
22|False|6D
23|False|6DK
24|False|6G
25|False|6GK
26|False|6GKK
27|False|7
28|False|8
29|False|8K
30|True|9
31|False|9C
32|False|9W
33|False|9L
34|False|10
35|False|1A
36|False|2A
37|False|1S
38|False|1SK
39|False|1SKK
40|False|3A
41|False|4A
42|False|4CA
43|False|4CC
44|False|5A
45|False|6A
46|False|6DA
47|False|6GA
48|False|7A
49|False|9N
50|False|9NW
\.

DROP TABLE IF EXISTS soil_slippage_potential ;
CREATE TABLE soil_slippage_potential (
 seq integer primary key,
 obsolete boolean not null,
 soilslippot varchar(15) unique,
 description text
);

COPY soil_slippage_potential from STDIN delimiter as '|';
1|False|Low|Low potential of slippage.
2|True|Moderately low|Moderately low hazzard of slippage.
3|False|Medium|Medium potential of slippage.
4|True|Moderately high|Moderately high hazard of slippage.
5|False|High|High potential of slippage.
\.

DROP TABLE IF EXISTS potential_frost_action ;
CREATE TABLE potential_frost_action (
 seq integer primary key,
 obsolete boolean not null,
 frostact varchar(8) unique,
 description text
);

COPY potential_frost_action (seq,obsolete,frostact) from STDIN delimiter as '|';
1|False|None
2|False|Low
3|False|Moderate
4|False|High
\.

DROP TABLE IF EXISTS hydrologic_group ;
CREATE TABLE hydrologic_group (
 seq integer primary key,
 obsolete boolean not null,
 hydgrp varchar(3) unique,
 description text
);

COPY hydrologic_group from STDIN delimiter as '|';
1|False|A| Soils in this group have low runoff potential when thoroughly wet. Water is transmitted freely through the soil.
2|False|B| Soils in this group have moderately low runoff potential when thoroughly wet. Water transmission through the soil is unimpeded.
3|False|C| Soils in this group have moderately high runoff potential when thoroughly wet. Water transmission through the soil is somewhat restricted.
4|False|D| Soils in this group have high runoff potential when thoroughly wet. Water movement through the soil is restricted or very restricted.
5|False|A/D| These soils have low runoff potential when drained and high runoff potential when undrained.
6|False|B/D| These soils have moderately low runoff potential when drained and high runoff potential when undrained.
7|False|C/D| These soils have moderately high runoff potential when drained and high runoff potential when undrained.
\.

DROP TABLE IF EXISTS corrosion_concrete ;
CREATE TABLE corrosion_concrete (
 seq integer primary key,
 obsolete boolean not null,
 corcon varchar(8) unique,
 description text
);

COPY corrosion_concrete (seq,obsolete,corcon) from STDIN delimiter as '|';
1|False|Low
2|False|Moderate
3|False|High
\.

DROP TABLE IF EXISTS corrosion_uncoated_steel ;
CREATE TABLE corrosion_uncoated_steel (
 seq integer primary key,
 obsolete boolean not null,
 corsteel varchar(8) unique,
 description text
);

COPY corrosion_uncoated_steel (seq,obsolete,corsteel) from STDIN delimiter as '|';
1|False|Low
2|False|Moderate
3|False|High
\.

DROP TABLE IF EXISTS taxonomic_family_c_e_act_class ;
CREATE TABLE taxonomic_family_c_e_act_class (
 seq integer primary key,
 obsolete boolean not null,
 taxceactcl varchar(11) unique,
 description text
);

COPY taxonomic_family_c_e_act_class from STDIN delimiter as '|';
1|False|not used|
2|False|subactive|The CEC7 to clay ratio is less than 0.24.
3|False|semiactive|The CEC7 to clay ratio is 0.24 to 0.40.
4|False|active|The CEC7 to clay ratio is 0.40 to 0.60.
5|False|superactive|The CEC7 to clay ratio is greater than or equal to 0.60.
\.

DROP TABLE IF EXISTS taxonomic_family_mineralogy ;
CREATE TABLE taxonomic_family_mineralogy (
 seq integer primary key,
 obsolete boolean not null,
 taxfammin varchar(29) unique,
 description text
);

COPY taxonomic_family_mineralogy (seq,obsolete,taxfammin) from STDIN delimiter as '|';
1|False|allitic
2|False|amorphic
3|True|calcareous
4|False|carbonatic
5|True|chloritic
6|True|clastic
7|False|coprogenous
8|False|diatomaceous
9|False|ferrihumic
10|False|ferrihydritic
11|False|ferritic
12|False|ferruginous
13|False|gibbsitic
14|False|glassy
15|False|glauconitic
16|False|gypsic
17|False|halloysitic
18|False|illitic
19|True|illitic (calcareous)
20|False|isotic
21|False|kaolinitic
22|False|magnesic
23|False|marly
24|False|micaceous
25|True|micaceous (calcareous)
26|False|mixed
27|True|mixed (calcareous)
28|True|montmorillonitic
29|True|montmorillonitic (calcareous)
30|False|not used
31|True|oxidic
32|False|paramicaceous
33|False|parasesquic
34|True|sepiolitic
35|True|serpentinitic
36|False|sesquic
37|False|siliceous
38|True|siliceous (calcareous)
39|False|smectitic
40|True|unclassified
41|False|vermiculitic
42|True|vermiculitic (calcareous)
\.

DROP TABLE IF EXISTS taxonomic_family_other ;
CREATE TABLE taxonomic_family_other (
 seq integer primary key,
 obsolete boolean not null,
 taxfamoth varchar(18) unique,
 description text
);

COPY taxonomic_family_other (seq,obsolete,taxfamoth) from STDIN delimiter as '|';
1|False|coated
2|False|cracked
3|True|level
4|False|micro
5|False|not used
6|False|ortstein
7|True|ortstein & shallow
8|False|shallow
9|True|shallow & coated
10|True|shallow & uncoated
11|True|sloping
12|True|unclassified
13|False|uncoated
\.

DROP TABLE IF EXISTS taxonomic_family_part_size_mod ;
CREATE TABLE taxonomic_family_part_size_mod (
 seq integer primary key,
 obsolete boolean not null,
 taxpartsizemod varchar(9) unique,
 description text
);

COPY taxonomic_family_part_size_mod from STDIN delimiter as '|';
1|False|aniso|This is used only to indicate that more than one pair of contrasting particle size families exist within the control section. (see Soil Taxonomy)
2|True|not aniso|
3|False|not used|Used to indicate that the soil does not qualify as "aniso".
\.

DROP TABLE IF EXISTS taxonomic_family_particle_size ;
CREATE TABLE taxonomic_family_particle_size (
 seq integer primary key,
 obsolete boolean not null,
 taxpartsize varchar(56) unique,
 description text
);

COPY taxonomic_family_particle_size (seq,obsolete,taxpartsize) from STDIN delimiter as '|';
1|False|ashy
2|False|ashy over clayey
3|False|ashy over clayey-skeletal
4|False|ashy over loamy
5|False|ashy over loamy-skeletal
6|False|ashy over medial
7|False|ashy over medial-skeletal
8|False|ashy over pumiceous or cindery
9|False|ashy over sandy or sandy-skeletal
10|False|ashy-pumiceous
11|False|ashy-skeletal
12|False|ashy-skeletal over fragmental or cindery
13|False|ashy-skeletal over loamy-skeletal
14|False|ashy-skeletal over sandy or sandy-skeletal
15|False|cindery
16|False|cindery over loamy
17|False|cindery over medial
18|False|cindery over medial-skeletal
19|True|cindery over sandy or sandy-skeletal
20|False|clayey
21|True|clayey over fine-silty
22|False|clayey over fragmental
23|False|clayey over loamy
24|False|clayey over loamy-skeletal
25|False|clayey over sandy or sandy-skeletal
26|False|clayey-skeletal
27|False|clayey-skeletal over sandy or sandy-skeletal
28|False|coarse-loamy
29|False|coarse-loamy over clayey
30|False|coarse-loamy over fragmental
31|False|coarse-loamy over sandy or sandy-skeletal
32|False|coarse-silty
33|False|coarse-silty over clayey
34|True|coarse-silty over fragmental
35|False|coarse-silty over sandy or sandy-skeletal
36|False|fine
37|False|fine-loamy
38|False|fine-loamy over clayey
39|False|fine-loamy over fragmental
40|False|fine-loamy over sandy or sandy-skeletal
41|False|fine-silty
42|False|fine-silty over clayey
43|False|fine-silty over fragmental
44|False|fine-silty over sandy or sandy-skeletal
45|False|fragmental
46|False|hydrous
47|False|hydrous over clayey
48|False|hydrous over clayey-skeletal
49|False|hydrous over fragmental
50|False|hydrous over loamy
51|False|hydrous over loamy-skeletal
52|False|hydrous over sandy or sandy-skeletal
53|False|hydrous-pumiceous
54|False|hydrous-skeletal
55|False|loamy
56|False|loamy over ashy or ashy-pumiceous
57|False|loamy over pumiceous or cindery
58|False|loamy over sandy or sandy-skeletal
59|False|loamy-skeletal
60|True|loamy-skeletal or clayey-skeletal
61|False|loamy-skeletal over cindery
62|False|loamy-skeletal over clayey
63|False|loamy-skeletal over fragmental
64|False|loamy-skeletal over sandy or sandy-skeletal
65|False|medial
66|False|medial over ashy
67|False|medial over ashy-pumiceous or ashy-skeletal
68|False|medial over clayey
69|False|medial over clayey-skeletal
70|False|medial over fragmental
71|False|medial over hydrous
72|False|medial over loamy
73|False|medial over loamy-skeletal
74|False|medial over pumiceous or cindery
75|False|medial over sandy or sandy-skeletal
76|True|medial over thixotropic
77|False|medial-pumiceous
78|False|medial-skeletal
79|False|medial-skeletal over fragmental or cindery
80|False|medial-skeletal over loamy-skeletal
81|False|medial-skeletal over sandy or sandy-skeltal
82|False|not used
83|False|pumiceous
84|False|pumiceous or ashy-pumiceous over loamy
85|False|pumiceous or ashy-pumiceous over loamy-skeltal
86|False|pumiceous or ashy-pumiceous over medial
87|False|pumiceous or ashy-pumiceous over medial-skeletal
88|False|pumiceous or ashy-pumiceous over sandy or sandy-skeletal
89|False|sandy
90|False|sandy or sandy-skeletal
91|False|sandy over clayey
92|False|sandy over loamy
93|False|sandy-skeletal
94|True|sandy-skeletal over clayey
95|False|sandy-skeletal over loamy
96|True|thixotropic
97|True|thixotropic over fragmental
98|True|thixotropic over loamy
99|True|thixotropic over loamy-skeletal
100|True|thixotropic over sandy or sandy-skeletal
101|True|thixotropic-skeletal
102|True|unclassified
103|False|very-fine
\.

DROP TABLE IF EXISTS taxonomic_family_reaction ;
CREATE TABLE taxonomic_family_reaction (
 seq integer primary key,
 obsolete boolean not null,
 taxreaction varchar(13) unique,
 description text
);

COPY taxonomic_family_reaction (seq,obsolete,taxreaction) from STDIN delimiter as '|';
1|False|acid
2|False|allic
3|False|calcareous
4|False|dysic
5|False|euic
6|False|nonacid
7|True|noncalcareous
8|False|not used
9|True|unclassified
\.

DROP TABLE IF EXISTS taxonomic_family_temp_class ;
CREATE TABLE taxonomic_family_temp_class (
 seq integer primary key,
 obsolete boolean not null,
 taxtempcl varchar(15) unique,
 description text
);

COPY taxonomic_family_temp_class (seq,obsolete,taxtempcl) from STDIN delimiter as '|';
1|False|frigid
2|False|hypergelic
3|False|hyperthermic
4|False|isofrigid
5|False|isohyperthermic
6|False|isomesic
7|False|isothermic
8|False|mesic
9|False|not used
10|False|pergelic
11|False|subgelic
12|False|thermic
13|True|unclassified
\.

DROP TABLE IF EXISTS taxonomic_great_group ;
CREATE TABLE taxonomic_great_group (
 seq integer primary key,
 obsolete boolean not null,
 taxgrtgroup varchar(16) unique,
 description text
);

COPY taxonomic_great_group (seq,obsolete,taxgrtgroup) from STDIN delimiter as '|';
1|False|Acraquox
2|True|Acrohumox
3|False|Acroperox
4|True|Acrorthox
5|False|Acrotorrox
6|False|Acrudox
7|False|Acrustox
8|True|Agrudalfs
9|False|Alaquods
10|False|Albaqualfs
11|False|Albaquults
12|False|Alorthods
13|True|Andaquepts
14|False|Anhyorthels
15|False|Anhyturbels
16|False|Anthracambids
17|False|Aquicambids
18|False|Aquisalids
19|False|Aquiturbels
20|False|Aquorthels
21|True|Arents
22|False|Argialbolls
23|False|Argiaquolls
24|True|Argiborolls
25|False|Argicryids
26|False|Argicryolls
27|False|Argidurids
28|False|Argigypsids
29|False|Argiorthels
30|False|Argiudolls
31|False|Argiustolls
32|False|Argixerolls
33|True|Borofibrists
34|True|Borofolists
35|True|Borohemists
36|True|Borosaprists
37|False|Calciaquerts
38|False|Calciaquolls
39|False|Calciargids
40|True|Calciborolls
41|False|Calcicryepts
42|False|Calcicryids
43|False|Calcicryolls
44|False|Calcigypsids
45|True|Calciorthids
46|False|Calcitorrerts
47|False|Calciudolls
48|False|Calciustepts
49|False|Calciusterts
50|False|Calciustolls
51|False|Calcixerepts
52|False|Calcixererts
53|False|Calcixerolls
54|True|Camborthids
55|True|Chromoxererts
56|True|Chromuderts
57|True|Chromusterts
58|True|Cryandepts
59|False|Cryaqualfs
60|False|Cryaquands
61|False|Cryaquents
62|False|Cryaquepts
63|False|Cryaquods
64|False|Cryaquolls
65|True|Cryoboralfs
66|True|Cryoborolls
67|True|Cryochrepts
68|False|Cryofibrists
69|False|Cryofluvents
70|False|Cryofolists
71|False|Cryohemists
72|True|Cryohumods
73|False|Cryopsamments
74|False|Cryorthents
75|True|Cryorthods
76|False|Cryosaprists
77|False|Cryrendolls
78|True|Cryumbrepts
79|True|Durandepts
80|False|Duraqualfs
81|False|Duraquands
82|False|Duraquerts
83|False|Duraquods
84|False|Duraquolls
85|True|Durargids
86|False|Duricryands
87|False|Duricryods
88|False|Duricryolls
89|False|Durihumods
90|False|Duritorrands
91|False|Durixeralfs
92|False|Durixerepts
93|False|Durixererts
94|False|Durixerolls
95|True|Durochrepts
96|True|Durorthids
97|False|Durorthods
98|False|Durudands
99|False|Durudepts
100|False|Durustalfs
101|False|Durustands
102|False|Durustepts
103|False|Durustolls
104|True|Dystrandepts
105|False|Dystraquerts
106|True|Dystrochrepts
107|False|Dystrocryepts
108|False|Dystrogelepts
109|True|Dystropepts
110|False|Dystroxerepts
111|False|Dystrudepts
112|False|Dystruderts
113|False|Dystrustepts
114|False|Dystrusterts
115|False|Endoaqualfs
116|False|Endoaquands
117|False|Endoaquents
118|False|Endoaquepts
119|False|Endoaquerts
120|False|Endoaquods
121|False|Endoaquolls
122|False|Endoaquults
123|False|Epiaqualfs
124|False|Epiaquands
125|False|Epiaquents
126|False|Epiaquepts
127|False|Epiaquerts
128|False|Epiaquods
129|False|Epiaquolls
130|False|Epiaquults
131|True|Eutrandepts
132|False|Eutraquox
133|True|Eutroboralfs
134|True|Eutrochrepts
135|True|Eutrocryepts
136|False|Eutrogelepts
137|True|Eutropepts
138|False|Eutroperox
139|True|Eutrorthox
140|False|Eutrotorrox
141|False|Eutrudepts
142|False|Eutrudox
143|False|Eutrustox
144|True|Ferrods
145|False|Ferrudalfs
146|False|Fibristels
147|False|Fluvaquents
148|False|Folistels
149|False|Fragiaqualfs
150|False|Fragiaquepts
151|False|Fragiaquods
152|False|Fragiaquults
153|True|Fragiboralfs
154|False|Fragihumods
155|True|Fragiochrepts
156|False|Fragiorthods
157|False|Fragiudalfs
158|False|Fragiudepts
159|False|Fragiudults
160|True|Fragiumbrepts
161|False|Fragixeralfs
162|False|Fragixerepts
163|False|Fraglossudalfs
164|False|Fulvicryands
165|False|Fulvudands
166|False|Gelaquands
167|False|Gelaquents
168|False|Gelaquepts
169|True|Gelicryands
170|False|Gelifluvents
171|False|Gelorthents
172|True|Gibbsiaquox
173|True|Gibbsihumox
174|True|Gibbsiorthox
175|False|Glacistels
176|False|Glossaqualfs
177|True|Glossoboralfs
178|False|Glossocryalfs
179|False|Glossudalfs
180|False|Gypsiargids
181|False|Gypsicryids
182|True|Gypsiorthids
183|False|Gypsitorrerts
184|False|Gypsiusterts
185|False|Halaquepts
186|False|Haplanthrepts
187|True|Haplaquands
188|True|Haplaquents
189|True|Haplaquepts
190|True|Haplaquods
191|True|Haplaquolls
192|False|Haplaquox
193|False|Haplargids
194|True|Haploborolls
195|False|Haplocalcids
196|False|Haplocambids
197|False|Haplocryalfs
198|False|Haplocryands
199|False|Haplocryepts
200|False|Haplocryerts
201|False|Haplocryids
202|False|Haplocryods
203|False|Haplocryolls
204|False|Haplodurids
205|False|Haplofibrists
206|False|Haplogelods
207|False|Haplogelolls
208|False|Haplogypsids
209|False|Haplohemists
210|False|Haplohumods
211|True|Haplohumox
212|False|Haplohumults
213|False|Haploperox
214|False|Haplorthels
215|False|Haplorthods
216|True|Haplorthox
217|False|Haplosalids
218|False|Haplosaprists
219|False|Haplotorrands
220|False|Haplotorrerts
221|False|Haplotorrox
222|False|Haploturbels
223|False|Haploxeralfs
224|False|Haploxerands
225|False|Haploxerepts
226|False|Haploxererts
227|False|Haploxerolls
228|False|Haploxerults
229|False|Hapludalfs
230|False|Hapludands
231|True|Hapludepts
232|False|Hapluderts
233|False|Hapludolls
234|False|Hapludox
235|False|Hapludults
236|True|Haplumbrepts
237|False|Haplustalfs
238|False|Haplustands
239|False|Haplustepts
240|False|Haplusterts
241|False|Haplustolls
242|False|Haplustox
243|False|Haplustults
244|False|Haprendolls
245|False|Hemistels
246|False|Historthels
247|False|Histoturbels
248|False|Humaquepts
249|False|Humicryepts
250|False|Humicryerts
251|False|Humicryods
252|False|Humigelods
253|True|Humitropepts
254|True|Hydrandepts
255|False|Hydraquents
256|False|Hydrocryands
257|False|Hydrudands
258|False|Kandiaqualfs
259|False|Kandiaquults
260|False|Kandihumults
261|False|Kandiperox
262|False|Kandiudalfs
263|False|Kandiudox
264|False|Kandiudults
265|False|Kandiustalfs
266|False|Kandiustox
267|False|Kandiustults
268|False|Kanhaplaquults
269|False|Kanhaplohumults
270|False|Kanhapludalfs
271|False|Kanhapludults
272|False|Kanhaplustalfs
273|False|Kanhaplustults
274|True|Luvifibrists
275|False|Luvihemists
276|True|Medifibrists
277|True|Medifolists
278|True|Medihemists
279|True|Medisaprists
280|False|Melanaquands
281|False|Melanocryands
282|False|Melanoxerands
283|False|Melanudands
284|False|Molliturbels
285|False|Mollorthels
286|True|Nadurargids
287|False|Natralbolls
288|False|Natraqualfs
289|False|Natraquerts
290|False|Natraquolls
291|False|Natrargids
292|True|Natriboralfs
293|True|Natriborolls
294|False|Natricryolls
295|False|Natridurids
296|False|Natrigypsids
297|False|Natrixeralfs
298|False|Natrixerolls
299|False|Natrudalfs
300|False|Natrudolls
301|False|Natrustalfs
302|False|Natrustolls
303|True|Ochraqualfs
304|True|Ochraquox
305|True|Ochraquults
306|False|Paleaquults
307|False|Paleargids
308|True|Paleboralfs
309|True|Paleborolls
310|False|Palecryalfs
311|False|Palecryolls
312|False|Palehumults
313|True|Paleorthids
314|False|Paleudalfs
315|False|Paleudolls
316|False|Paleudults
317|False|Paleustalfs
318|False|Paleustolls
319|False|Paleustults
320|False|Palexeralfs
321|False|Palexerolls
322|False|Palexerults
323|True|Pelloxererts
324|True|Pelluderts
325|True|Pellusterts
326|False|Petraquepts
327|False|Petroargids
328|False|Petrocalcids
329|False|Petrocambids
330|False|Petrocryids
331|False|Petrogypsids
332|True|Placandepts
333|False|Placaquands
334|True|Placaquepts
335|False|Placaquods
336|False|Placocryods
337|False|Placohumods
338|False|Placorthods
339|False|Placudands
340|False|Plagganthrepts
341|True|Plaggepts
342|False|Plinthaqualfs
343|True|Plinthaquepts
344|False|Plinthaquox
345|False|Plinthaquults
346|False|Plinthohumults
347|False|Plinthoxeralfs
348|False|Plinthudults
349|False|Plinthustalfs
350|False|Plinthustults
351|False|Psammaquents
352|False|Psammorthels
353|False|Psammoturbels
354|False|Quartzipsamments
355|True|Rendolls
356|False|Rhodoxeralfs
357|False|Rhodudalfs
358|False|Rhodudults
359|False|Rhodustalfs
360|False|Rhodustults
361|False|Salaquerts
362|False|Salicryids
363|False|Salitorrerts
364|True|Salorthids
365|False|Salusterts
366|False|Sapristels
367|True|Sideraquods
368|True|Sombrihumox
369|False|Sombrihumults
370|True|Sombriorthox
371|False|Sombriperox
372|True|Sombritropepts
373|False|Sombriudox
374|False|Sombriustox
375|False|Sphagnofibrists
376|False|Sulfaquents
377|False|Sulfaquepts
378|False|Sulfaquerts
379|False|Sulfihemists
380|False|Sulfisaprists
381|True|Sulfochrepts
382|False|Sulfohemists
383|False|Sulfosaprists
384|False|Sulfudepts
385|True|Torrerts
386|False|Torriarents
387|False|Torrifluvents
388|False|Torrifolists
389|False|Torriorthents
390|False|Torripsamments
391|True|Torrox
392|True|Tropaqualfs
393|True|Tropaquents
394|True|Tropaquepts
395|True|Tropaquods
396|True|Tropaquults
397|True|Tropofibrists
398|True|Tropofluvents
399|True|Tropofolists
400|True|Tropohemists
401|True|Tropohumods
402|True|Tropohumults
403|True|Tropopsamments
404|True|Troporthents
405|True|Troporthods
406|True|Troposaprists
407|True|Tropudalfs
408|True|Tropudults
409|False|Udarents
410|False|Udifluvents
411|False|Udifolists
412|False|Udipsamments
413|False|Udivitrands
414|False|Udorthents
415|True|Umbraqualfs
416|True|Umbraquox
417|False|Umbraquults
418|True|Umbriorthox
419|False|Umbriturbels
420|False|Umbrorthels
421|False|Ustarents
422|False|Ustifluvents
423|False|Ustifolists
424|False|Ustipsamments
425|False|Ustivitrands
426|True|Ustochrepts
427|False|Ustorthents
428|True|Ustropepts
429|False|Vermaqualfs
430|False|Vermaquepts
431|True|Vermiborolls
432|False|Vermudolls
433|False|Vermustolls
434|True|Vitrandepts
435|False|Vitraquands
436|False|Vitricryands
437|False|Vitrigelands
438|False|Vitritorrands
439|False|Vitrixerands
440|False|Xerarents
441|True|Xerochrepts
442|False|Xerofluvents
443|False|Xeropsamments
444|False|Xerorthents
445|True|Xerumbrepts
\.

DROP TABLE IF EXISTS taxonomic_moisture_class ;
CREATE TABLE taxonomic_moisture_class (
 seq integer primary key,
 obsolete boolean not null,
 taxmoistcl varchar(15) unique,
 description text
);

COPY taxonomic_moisture_class (seq,obsolete,taxmoistcl) from STDIN delimiter as '|';
1|False|Aquic
2|False|Aridic (torric)
3|False|Peraquic
4|False|Perudic
5|False|Udic
6|False|Ustic
7|False|Xeric
\.

DROP TABLE IF EXISTS taxonomic_moisture_subclass ;
CREATE TABLE taxonomic_moisture_subclass (
 seq integer primary key,
 obsolete boolean not null,
 taxmoistscl varchar(15) unique,
 description text
);

COPY taxonomic_moisture_subclass (seq,obsolete,taxmoistscl) from STDIN delimiter as '|';
1|False|Aeric
2|False|Anthraquic
3|False|Aquic
4|False|Aridic (torric)
5|False|Oxyaquic
6|False|Typic
7|False|Udic
8|False|Ustic
9|False|Xeric
\.

DROP TABLE IF EXISTS taxonomic_order ;
CREATE TABLE taxonomic_order (
 seq integer primary key,
 obsolete boolean not null,
 taxorder varchar(11) unique,
 description text
);

COPY taxonomic_order (seq,obsolete,taxorder) from STDIN delimiter as '|';
1|False|Alfisols
2|False|Andisols
3|False|Aridisols
4|False|Entisols
5|False|Gelisols
6|False|Histosols
7|False|Inceptisols
8|False|Mollisols
9|False|Oxisols
10|False|Spodosols
11|False|Ultisols
12|False|Vertisols
\.

DROP TABLE IF EXISTS taxonomic_suborder ;
CREATE TABLE taxonomic_suborder (
 seq integer primary key,
 obsolete boolean not null,
 taxsuborder varchar(9) unique,
 description text
);

COPY taxonomic_suborder (seq,obsolete,taxsuborder) from STDIN delimiter as '|';
1|False|Albolls
2|True|Andepts
3|False|Anthrepts
4|False|Aqualfs
5|False|Aquands
6|False|Aquents
7|False|Aquepts
8|False|Aquerts
9|False|Aquods
10|False|Aquolls
11|False|Aquox
12|False|Aquults
13|False|Arents
14|False|Argids
15|True|Boralfs
16|True|Borolls
17|False|Calcids
18|False|Cambids
19|False|Cryalfs
20|False|Cryands
21|False|Cryepts
22|False|Cryerts
23|False|Cryids
24|False|Cryods
25|False|Cryolls
26|False|Durids
27|True|Ferrods
28|False|Fibrists
29|False|Fluvents
30|False|Folists
31|False|Gelands
32|False|Gelepts
33|False|Gelods
34|False|Gelolls
35|False|Gypsids
36|False|Hemists
37|False|Histels
38|False|Humods
39|True|Humox
40|False|Humults
41|True|Ochrepts
42|False|Orthels
43|False|Orthents
44|True|Orthids
45|False|Orthods
46|True|Orthox
47|False|Perox
48|True|Plaggepts
49|False|Psamments
50|False|Rendolls
51|False|Salids
52|False|Saprists
53|False|Torrands
54|False|Torrerts
55|False|Torrox
56|True|Tropepts
57|False|Turbels
58|False|Udalfs
59|False|Udands
60|False|Udepts
61|False|Uderts
62|False|Udolls
63|False|Udox
64|False|Udults
65|True|Umbrepts
66|False|Ustalfs
67|False|Ustands
68|False|Ustepts
69|False|Usterts
70|False|Ustolls
71|False|Ustox
72|False|Ustults
73|False|Vitrands
74|False|Xeralfs
75|False|Xerands
76|False|Xerepts
77|False|Xererts
78|False|Xerolls
79|False|Xerults
\.

DROP TABLE IF EXISTS taxonomic_temp_regime ;
CREATE TABLE taxonomic_temp_regime (
 seq integer primary key,
 obsolete boolean not null,
 taxtempregime varchar(19) unique,
 description text
);

COPY taxonomic_temp_regime (seq,obsolete,taxtempregime) from STDIN delimiter as '|';
1|False|cryic
2|True|Cryic (PDP code)
3|False|frigid
4|False|hyperthermic
5|False|isofrigid
6|False|isohyperthermic
7|False|isomesic
8|False|isothermic
9|False|mesic
10|True|pergelic
11|True|Pergelic (PDP code)
12|False|thermic
\.

DROP TABLE IF EXISTS soil_taxonomy_edition ;
CREATE TABLE soil_taxonomy_edition (
 seq integer primary key,
 obsolete boolean not null,
 soiltaxedition varchar(15) unique,
 description text
);

COPY soil_taxonomy_edition (seq,obsolete,soiltaxedition) from STDIN delimiter as '|';
1|False|tenth edition
2|False|ninth edition
3|False|eighth edition
4|False|seventh edition
5|False|sixth edition
6|False|fifth edition
7|False|fourth edition
8|False|third edition
9|False|second edition
10|False|first edition
\.

DROP TABLE IF EXISTS fl_soil_leaching_potential ;
CREATE TABLE fl_soil_leaching_potential (
 seq integer primary key,
 obsolete boolean not null,
 flsoilleachpot varchar(6) unique,
 description text
);

COPY fl_soil_leaching_potential from STDIN delimiter as '|';
1|False|Low|Slowest permeability is 0.6 in/hr or less. Soils with a muck/peat layer are rated "low".
2|False|Medium|Slowest permeability is between 0.6 and 6.0 in/hr. Soils with a mucky layer are rated "medium" unless the soil has a slowest permeability of less than 0.6 in/hr. Then the soil is rated "low".
3|False|High|Slowest permeability is 6.0 in/hr or more.
\.

DROP TABLE IF EXISTS fl_soil_runoff_potential ;
CREATE TABLE fl_soil_runoff_potential (
 seq integer primary key,
 obsolete boolean not null,
 flsoirunoffpot varchar(6) unique,
 description text
);

COPY fl_soil_runoff_potential from STDIN delimiter as '|';
1|False|Low|Soils with a hydrological group of A, and soils with a hydrological group of B (in their natural, undrained state) that have a permeability of 6.0 in/hr or greater in all of the upper 20 inches of the soil.
2|False|Medium|Soils with a hydrological group of C, and soils with a hydrological group of B (in their natural, undrained state) that have a permeability of less than 6.0 in/hr within 20 inches of the soil surface. Soils that rate low are changed to a rating of medium where the slope is more than 12 percent.
3|False|High|Soils with a hydrological group of D in their natural, undrained state. Soils that are frequently flooded during the growing season are rated high.  Soils that rate medium are changed to a rating of high where the slope is more than 8 percent.
\.

DROP TABLE IF EXISTS mi_soil_management_group ;
CREATE TABLE mi_soil_management_group (
 seq integer primary key,
 obsolete boolean not null,
 misoimgmtgrp varchar(7) unique,
 description text
);

COPY mi_soil_management_group (seq,obsolete,misoimgmtgrp) from STDIN delimiter as '|';
1|False|0a
2|False|0b
3|False|0c
4|False|1.5a
5|False|1.5a-s
6|False|1.5b
7|False|1.5b-s
8|False|1.5c
9|False|1.5c-c
10|False|1/5a
11|False|1/Rbc
12|False|1a
13|False|1b
14|False|1c
15|False|1c-c
16|False|2.5a
17|False|2.5a-a
18|False|2.5a-af
19|False|2.5a-cs
20|False|2.5a-d
21|False|2.5a-s
22|False|2.5b
23|False|2.5b-cd
24|False|2.5b-cs
25|False|2.5b-d
26|False|2.5b-s
27|False|2.5c
28|False|2.5c-c
29|False|2.5c-cs
30|False|2.5c-s
31|False|2/3a-f
32|False|2/Ra
33|False|2/Rb
34|False|2/Rbc
35|False|3/1a
36|False|3/1b
37|False|3/1c
38|False|3/2a
39|False|3/2a-d
40|False|3/2a-f
41|False|3/2b
42|False|3/2b-d
43|False|3/2c
44|False|3/5a
45|False|3/5a-a
46|False|3/5b
47|False|3/5b-c
48|False|3/5c
49|False|3/Ra
50|False|3/Rbc
51|False|3a
52|False|3a-a
53|False|3a-af
54|False|3a-d
55|False|3a-f
56|False|3a-s
57|False|3b
58|False|3b-a
59|False|3b-af
60|False|3b-s
61|False|3c
62|False|3c-s
63|False|4/1a
64|False|4/1b
65|False|4/1c
66|False|4/2a
67|False|4/2a-f
68|False|4/2a-hs
69|False|4/2b
70|False|4/2b-s
71|False|4/2c
72|False|4/2c-c
73|False|4/Ra
74|False|4/Rbc
75|False|4a
76|False|4a-a
77|False|4a-af
78|False|4a-h
79|False|4b
80|False|4c
81|False|5.3a
82|False|5.7a
83|False|5/2a
84|False|5/2b
85|False|5/2b-h
86|False|5/2c
87|False|5a
88|False|5a-a
89|False|5a-h
90|False|5b
91|False|5b-h
92|False|5c
93|False|5c-a
94|False|5c-c
95|False|5c-h
96|False|G/Ra
97|False|G/Rbc
98|False|Ga
99|False|Ga-d
100|False|Ga-f
101|False|Gbc
102|False|Gbc-af
103|False|Gc-cd
104|False|L-2a
105|False|L-2b
106|False|L-2c
107|False|L-2c-c
108|False|L-4a
109|False|L-4c
110|False|L-Mc
111|False|M/1c
112|False|M/3c
113|False|M/3c-a
114|False|M/4c
115|False|M/4c-a
116|False|M/mc
117|False|M/Ra
118|False|M/Rc
119|False|Mc
120|False|Mc-a
121|False|Ra
122|False|Rbc
\.

DROP TABLE IF EXISTS va_soil_management_group ;
CREATE TABLE va_soil_management_group (
 seq integer primary key,
 obsolete boolean not null,
 vasoimgtgrp varchar(2) unique,
 description text
);

COPY va_soil_management_group (seq,obsolete,vasoimgtgrp) from STDIN delimiter as '|';
1|False|QQ
2|False|PP
3|False|OO
4|False|NN
5|False|MM
6|False|LL
7|False|KK
8|False|JJ
9|False|II
10|False|HH
11|False|GG
12|False|FF
13|False|EE
14|False|DD
15|False|CC
16|False|BB
17|False|AA
18|False|Z
19|False|Y
20|False|X
21|False|W
22|False|V
23|False|U
24|False|T
25|False|S
26|False|R
27|False|Q
28|False|P
29|False|O
30|False|N
31|False|M
32|False|L
33|False|K
34|False|J
35|False|I
36|False|H
37|False|G
38|False|F
39|False|E
40|False|D
41|False|C
42|False|B
43|False|A
\.

--DROP TABLE IF EXISTS # ;
--CREATE TABLE # (
-- seq integer primary key,
-- obsolete boolean not null,
-- # varchar(#) unique,
-- description text
--);
--COPY # from STDIN delimiter as '|';
--COPY # (seq,obsolete,#) from STDIN delimiter as '|';


