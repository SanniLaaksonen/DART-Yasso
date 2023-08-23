How to run Yasso assimilations with R and DART (yleisohje):

1. Create initial state file and the truth:
	1.1 R script: Yasso20_vakioajo.R
	    - Run the True state scenario (Truth):
	      Kootaan totuusajon lähtöarvot ja ajetaan init-tilanne 2022 vakiosyötteillä.
   	      Luotiin uudelleenkäytettävät karikesyötteet, jotka nykyisin luetaan tallennetuista tiedostoista.
	      Ajaa vuodet 2023-2099 ja tallentaa tulokset.
	      Lopussa myös yksinkertainen plottausmahdollisuus.
	    Input: Parameters from ParY20.dat, Yasso20_clim.r to get climate data, the model itself Yasso20.r
	    Truth Output: Nimet ovat samat kuin simulaatio skenaariolla, mutta ilman viimeistä s-kirjainta. (meluttomat versiot)
	                  esim. tässä total_SOC_2399.dat (Tallennettu Yasso/Yassodatat/Simulated_Truth)

	1.2 R script: Yasso20_run_csimul.R
	    - Runs the Simulated scenario without the assimilations (no_SDA)
	      Vastaava kuin totuusajo yllä, mutta meluisa ja syötteitä aliarvioitu tarkoituksella.
	    Input: Parameters from ParY20.dat, Yasso20_clim.r to get climate data, the model itself Yasso20.r 
	    Simulation Output: initial_state_*.dat (I chose initial_state_22s.dat --> where s=simulationrun, year 2022),
			       total_SOC_2399s.dat, SOCpools_2399s.dat, precip_2399s.dat, temp_2399s.dat, litter_2399s.dat, litter_awenh_2399s.dat
	    (Ensimmäisellä ajokerralla tallensin tämän scriptin omaan käyttöön myös: cpro_As.dat, cpro_Ws.dat, cpro_Es.dat, cpro_Ns.dat, caddnoise_s.dat, joita nyt käytän pitämään simulaatioajon tuloksen muuttumattomana)
			       

2. Create initial ensemble: 
  - R script: Creating_initial_ensemble.R
	      This code reads in the initial state, where the carbon is divided into the pools (not the fractions), and creates an ensemble from it. 
	      The code does this one site at a time. Remember to change both input and output filenames when moving to another initial state in time.
	      Variance (var) was increased from 0.1 to 0.2.
 	      Input: initial_state_*.dat (I chose initial_state_22s.dat)
	      Output: ensemble_*.dat (I chose ensemble_22s.dat)

3. Create observations (for example 5, 10 and 15 years after the initial year 2022)
  - R script: SOC_obs_yasso.R 
	- Anna funktiokutsussa observed_years -lista esim. c(5,10,15) haluamiesi havaintovuosien mukaan. Poista # write-komennon edestä ja nimeä luotava tiedosto haluamallasi tavalla.
	  Funktio lisää valittujen vuosien totuusajon arvoihin toistaiseksi Ultunan keskivirheen suuruisella hajonnalla (sd) melua.
          Tallentaa kolme havaintoa tiedostoon, jota käytetään obs_seq.out tiedostojen luomiseen.
	  (Loppuun lisätty mahdollisuus tallentaa vain 1, 2, tai kaikki 3 lukua, jotta filter_restart saadaan ulos myös assimilaatioiden 1 ja 2 ensemblejen keräämistä varten DART-ajoissa. Liittyy ensemble-kuvaajiin, joiden ohjeet alempana)
	Init: total_SOC_2399.dat (Totuusajon total SOC, HUOM. varmista että ET VALITSE vastaavaa simulaatioajon dataa, jonka tunnistaa s-kirjaimesta lopussa)
	Output: havainnot_*.dat (I used havainnot_tonni.dat (5_10_15), havainnot_t369 (3_6_9), havainnot_t102030 (10_20_30))


4. Creating input files for DART:

   4.1 filter_ics
   - R script: Init_for_dart_classic.R
	- Add the correct path to the input file into "path" and run.
	- Make sure the units are kg C/m2
	- The output files are created into current directory.
	Input: ensemble_*.dat (I chose ensemble_22s.dat)
	Output: filter_ics (I chose filter_ics_Simul)
	- For the updated version of the code, filter_ics needs to be formatted differently. The updated code is found in the Init_for_dart_classic_split.R file
	Input: Input: ensemble_*.dat (I chose ensemble_22s.dat)
	Output: filter_ics (I chose filter_ics_Simul), init_ensemble.dat

   4.2 Obs_seq.out
   - R script: Obs_for_dart_classic.R
	- I added the variable "filename" to make changing the name of the output file easier.
	- Add the correct path to the input file into "path" (possibly change the filename) and run.
	- The output files are created into current directory.
	Input: havainnot_*.dat (I used havainnot_tonni.dat (5_10_15), havainnot_t369 (3_6_9), havainnot_t102030 (10_20_30))
	Output: Obs_seq*.out (I chose Obs_seq_Simul.out)

   4.3 Litter and climate data
   - R script: clim_obs_yassodart.R
	- Input climate data was created during the simulationrun in Yasso20_run_csimul.R by calling the function "Yasso20_clim.r"
	  --> This function reads rainfall and temperature data (2000-2099) from the netCDF files "yearsum.pre.nc" and "monmean_tmp.nc".
	      yearsum.pre.nc yksiköt korjattiin vastaamaan kertymää millimetreinä vuodessa. Lämpötilaksi kirjattiin kuukauden minimi ja maksililämpötilojen keskiarvo asteina.
	- Input litter data litter_awenh_2399s.dat was also calculated and saved during the simulationrun in Yasso20_run_csimul.R

	- I corrected the units from g C/m2 to kg C/m2, combined the data with the correct years and formatted it as a dataframe.
	Input: precip_2399s.dat, temp_2399s.dat, litter_awenh_2399s.dat
	Output: Simul_litter.dat, Simul_clim.dat
   

5. Runnig DART
   - When running DART in csc taito server I needed to load the following modules for the codes to work:
$ module load netcdf/4.7.0
$ module load netcdf-fortran/4.4.4
  - mkmf.template must have the matching netCDF and compiler settings:
	NETCDF = /appl/spack/install-tree/intel-19.0.4/netcdf-4.7.0-5xwiij
	FC = ifort
	LD = ifort

  - Make sure you have the correct settings in input.nml (inflation, filenames etc.)
  - Add the input files into your work directory DART/models/yasso/work
  - Add the input litter and climate data (Input: I chose Simul_litter.dat, Simul_clim.dat)
    to the file location given in the Yasso code (DART/models/yasso/model/yasso.f90)
	- Compile after changes!

  - Run ./quickbuild.csh and ./preprocess
  - Run the DA with ./filter
Input files: filter_ics, obs_seq.out (I chose filter_ics_Simul, Obs_seq_Simul.out) --> Choose the correct observation file (esim. 5_10_15 kansiosta, jos tutkit näitä vuosia), filter_ics_Simul stays the same
Output files: obs_seq.final, Prior_Diag.nc, Posterior_Diag.nc (In my case Obs_seq_Simul.final)

######################
How to create the ENVELOPE PLOT: (Tutkitaan vain yhtä vuosisettiä kerrallaan. Kirjoitan tämän 5_10_15 perusteella)

   - Tarvitaan assimilaatiohetkien jälkeisten ennusteiden kaikki 50 ensemblejäsentä (3 kpl 50 kappaleen init-settejä, yksi joka assimilaatiolle)
     Luin ne filter_restart* tiedostoista, mutta 1. ja 2. assimilaation tapauksessa Obs_seq_Simul.out tiedostosta piti
     poistaa havaintoja, jotta ajo keskeytyy halutussa kohdassa.

1. Havaintotiedostojen pilkkominen
 1.1
   R script: SOC_obs_yasso.R 
	- Siirry skriptin loppun kohtaan "Havainnot osissa" ja valitse tutkimasi vuosisetin aiemmin luotu havaintotiedosto esim. nyt havainnot_tonni.dat (5_10_15).
	  (Jos sitä ei vielä ole, aja tämän skriptin alku samoin kuin ylläolevan ohjeen kohdassa "3. Create observations" poistamalla # oikean vuosisettikutsun edestä.)
	- Aja viimeisen rivin write-komento
	  Tallentaa vain 1, 2, tai kaikki 3 lukua, jotta filter_restart saadaan ulos myös assimilaatioiden 1 ja 2 ensemblejen keräämistä varten DART-ajoissa.
	Init: total_SOC_2399.dat (Totuusajon total SOC, HUOM. varmista että ET VALITSE vastaavaa simulaatioajon dataa, jonka tunnistaa s-kirjaimesta lopussa)
	Output: havainnot_*.dat (I used havainnot_tonni1.dat ja havainnot_tonni2.dat (5_10_15))
	(havainnot_t369_1as3.dat ja havainnot_t369_2as6.dat (3_6_9), havainnot_t102030_1as10.dat ja havainnot_t102030_2as20.dat (10_20_30))

 1.2 Aiemmin luotujen kolmen havainnon tiedostojen, eli havainnot_tonni.dat (5_10_15), havainnot_t369 (3_6_9) ja havainnot_t102030 (10_20_30), avulla saadaan suoraan filter_restart assimilaatiolle 3.
     Siksi tälle ei tarvita uutta Obs_seq_Simul.out tiedostoa (luotu yleisohjeessa yllä).

2. Luo uudet Obs_seq_Simul*.out tiedostot puuttuville assimilaatioille (1st and 2nd) uusien havaintotiedostojen avullau
   Kuten yleisohjeen kohdassa 4.2: 
    - R script: Obs_for_dart_classic.R
   Input: havainnot_tonni1.dat ja havainnot_tonni2.dat (5_10_15)
   Output: (5_10_15: Obs_seq_Simul_5_as1.out, Obs_seq_Simul_10_as2.out)

3. Aja DART 3 kertaa uudelleen ./filter komennolla vaihtamalla Obs_seq_Simul.out tiedosto joka välissä. (5_10_15: Obs_seq_Simul_5_as1.out, Obs_seq_Simul_10_as2.out, Obs_seq_Simul.out)
   Tallenna joka ajon jälkeen filter_restart eri nimellä (5_10_15: filter_restart_5y, filter_restart_10y, filter_restart_15y) ('_inf1' lisätty versioon, jossa käytettiin inflaatiokerrointa 1.0)

4. DART tulosten luku (50 inits per assimilation) ja plottausvaihe
   - R script: Envelope_kuvaaja_yasso.R:

   4.1 Luin kaikkien kolmen filter_restart-tiedoston sisällöt yksitellen helppolukuisempiin ensemble_*y.dat (* esim. 5 10 15)
   4.2 Aja ensemblet:
	- Aja Yassolla jokaisen assimilaation kaikki ensemblejäsenet (3 toistoa joissa i in 1:50 looppi)
	  havaintovuoden jälkeisestä vuodesta (2022 + * + 1) loppuun (2099):
	  HUOM_1: Muista vaihtaa toistojen välissä oikea tiedosto kohtaan 'ensemble = '
	  HUOM_2: Muuta 3 toiston välissä myös "step = * + 1", missä * vastaa kuluneiden vuosien määrää (5, 10, 15)
	  HUOM: Tallenna toistojen tulokset yksitellen kohdassa "save results"
	Input:  ensemble_*y.dat   (3 kpl: * = 5, 10, 15)
	Output: ensemblerun_*.dat (3 kpl: * = 5, 10, 15)
   4.3 Koosta envelopejen keskiarvot ja ylä- sekä alarajat:
	- Luo mean_soc#, soc_upper#, soc_lower# , missä # = c(0,1,2,3) (0=no_SDA, 1=assimilation 1 (5), 2=assimilation 2 (10), 3=assimilation 3 (15))
	  --> Valitse # assimilaation "ensemblerun_*.dat"-tiedosto. esim. ensemblerun_5.dat HUOM: no_SDA ajo on tallennettu tiedostoon "ensemblerun_1.dat" (luotu kohdan 4.2 tavoin yleisohjeessa luodusta tiedostosta "ensemble_22s.dat")
	      ja aja vastaavat rivit esim. mean_soc1 jne. ensimmäiselle assimilaatiovuosista
   4.4 Plottaus
       - Jatka ajamalla ensin oikean vuosisetin kohdalta totuusajon, simulaation, havaintojen ja assimilaatioiden datat ja vuodet muuttujiin.
       - Siirry kohtaan #All ja aja loput rivit, jolloin ggplot tulostaa envelope-kuvaajan valitsemallesi vuodelle.

Jos kaikki tiedostot on jo valmiiksi luotu ja haluat vain piirtää plotin, siirry suoraan skriptin kohtaan #PLOTTAUS (Noudata tämän ohjeen kohtia 4.3 ja 4.4).
   
   4.5 Plottaus useamman palstan kuvaajille:
   HUOM! Käytettävävät R-koodit ovat nimetty _all
       - R script: Envelope_kuvaaja_yasso_all.R
       - Ennen DART:in ajoa lataa moduulit:
       module load netcdf
       module load netcdf fortran
       - Aja DART n kertaa muuttamalla jokaisen kerran jälkeen yasso_filter.csh:n loopin numeroa (jossa n on havaintojen määrä).
       - DART ajetaan yasso_filter.csh -tiedostolla work-kansiosta. Tarkista että tiedostopolut, kopioitavien tiedostojen ja suoritettavan assimilaation loopin numero on oikein.
       Input:
       - Obs_seq_1.out, obs_seq_2.out, obs_seq_3.out ... obs_seq_n.out. Luo nämä R:llä samoin tavoin kun yllä luodaan obs_seq.out tiedosto, mutta käytä ajoon Obs_for_dart_classic.R tiedoston sijaan tiedostoa Obs_for_dart_classic_all.R.
       - Simul_litter_1.dat, ... Simul_litter_n.dat palstoittain
       - Simul_clim.dat
       - years.dat luodaan havaintotiedostojen koodissa
       - ens_projection_sites.dat kaikki palstat samassa
       - Init_ensemble_split_1.dat ... init_ensemble_split_n.dat palstoittain
       
       Output: init_ensemble_split_n (palstat x n kpl jossa n on assimilaation numero. Jokaiselle palstalle tulee oma tiedosto per assimilaatio). Tallenna tämä jokaisen ajon jälkeen, koska se ylikirjoitetaan.
       HUOM! DARTiin tehtävät muutokset kun palstojen määrä muuttuu:
       	- Input.nml: Model_size = 6*palstat, esim. 12 kun palstoja on 2. Sijaitsee work kansiossa.
	- Model_mod.f90: sijaitsee models/yasso kansiossa. Kun muutat Model_mod.f90, aja myös quickbuild.sh work-kansiossa (EI model kansiossa).
	- Model_size = 6*palstat, esim. 12 kun palstoja on 2
	- Tällä hetkellä lokaatiovektori on määritetty käsin testausta varten. Voidaan myös lukea loopista.
	- ReadOut.f90: sites lukumäärä
	- yasso.f90: sites lukumäärä
	- CreateInit.f90: n-arvo riippuu palstojen määrästä. Lokaatiovektori määritellään tällä hetkellä käsin
	- Muuta nämä tiedostot ja compilaa ne muutosten jälkeen uudelleen.
	- Tarkista että vanha filter_output_yasso.nc on poistettu work-kansiosta, kun muutat palstojen kokoa.
       
       - Siirry Envelope_kuvaaja_yasso_all.R scriptissä kohtaan "Run Yasso20 with each init of the ensemble". Aja yasso erikseen jokaiselle init_ensemblelle ja tallenna tiedostot palstoittain. HUOM! Yasson ajokoodiin pitää muuttaa käsiteltävissä oleva vuosi sekä litter.
       Input: init_enseble_split_1, init_ensemble_split_2, init_ensemble_split_3, ... init_ensemble_split_n (HUOM! Jokainen assimilaatio tuottaa n määrän ensemblejä, jotka DART:issa ovat nimetty init_ensemble_split_1 jne. Kun viet ne takaisin R:ään, muuta niiden nimet siten että numero kertoo assimilaation numeron palstan numeron sijaan ja tee tämä kaikille palstoille erikseen.)
       Output: ensemble_yasso1, ensemble_yasso2, ensemble_yasso3
       -Siirry kohtaan 4.3, seuraa ohjeita mutta käytä edelleen Envelope_kuvaaja_yasso_all.R koodia. Ensemble_yasso jne. vastaavat ohjeen ensemblerun_1 jne. tiedostoja. 

HUOM! Muutettaessa DART-tiedostoja jos ReadOut ei löydä moduuleita, käytä polkua:
-I/appl/spack/v018/install-tree/gcc-11.3.0/netcdf-fortran-4.5.4-p6xyan/include -L/appl/spack/v018/install-tree/gcc-11.3.0/netcdf-fortran-4.5.4-p6xyan/lib -lnetcdff -lnetcdf

 
######################
How to create the PREDICTION PLOT (10 pätkistä koottua ennustemurtoviivaa ja totuus) and the error table:
(10 lines that combine no_SDA and the assimilations (Truth also plotted next to those))

1. Luodaan 10 eri havaintotiedostoa ja niille omat Obs_seq_Simul.out tiedostot.
   SOC_obs_yasso.R	ja	Obs_for_dart_classic.R avulla, kuten yleisohjeen kohdissa 3 ja 4.2 (filename avulla Obs_seq_Simul.out nimen perään voi lisätä indeksejä vaivattomasti)

2. Ajetaan DART 10 kertaa vaihtamalla joka välissä Obs_seq_Simul.out tiedostoa.
   - Poista ylimääräiset indeksit Obs_seq_Simul.out nimen perästä (jos lisäsit niitä) TAI muokkaa init.nml:ää, jotta DART löytää havainnot.
   - Tallennetaan jokaisen ajon output Posterior_Diag.nc eri nimellä (10 kpl per vuosisetti) esim. Posterior_Diag_*.nc, missä * vastaa lukuja 1-10.
   - Muita syötedatoja ei tarvitse vaihtaa yleisohjeeseen nähden.

3. Piirtovaihe
 3.1 Ajetaan Yasso
 - R script: Multiennuste_yasso_automatisoitu.R
	Lukee 10:stä eri Posterior_Diag.nc tiedosta 10 eri initial state arvoa jokaiselle assimilaatiovuodelle (esim. 5,10,15)
	Ajaa Yasson 10 eri lähtötilanteesta loppuun (2099). Ensin 10:stä vuoden 5 lähtötilanteesta alkaen ja vastaavasti muut 2.
	---> Aseta posterior_path kansioksi se, jossa tutkimasi vuosisetin Posterior_Diag_*.nc (10 kpl) ovat.
	     Aseta obs_skip = 5 ja assim_num = 1, kun tutkit viiden vuoden päästä kerättyjä states-arvoja.
 	     Toista vastaavasti (10,2) ja (15,3), mutta tallenna edelliset SOC_development ja H_development ennen loopin aloittamista uudelleen.
	---> Tallentaa total_SOC (10obsrun_*y.dat) ja Hpool (10obsrun_*H.dat) arvot jokaiselle vuodelle. (* = 5,10 tai 15 init-hetkestä riippuen)
 3.2 Koonti ja plottaus
	- Lue äsken tallennetuista tiedostoista aikasarjat muuttujiin no_SDA, as1, as2 ja as3. Aja vain tutkimasi vuosisetin rivit.
	- # all: ja ### plotataan 10 viivasettiä hoitavat plottausvaiheen loppuun. HUOM: päivitä plotin otsikko.

4. VIRHE TAULUKKO (saman skriptin Multiennuste_yasso_automatisoitu.R loppuosassa)
  - Aja kohdan #luodaan_murtoviivat  jälkeiset oikean vuosisetin rivit ja # all: ennen plottausvaihetta uudelleen, jotta allobs-muuttujassa on tallentuneena oikea vuosisetti.
    Jatka kohtaan table, ja aja loput komennot kunnes olet tallntanut error5_10_15 ja sd1 (muuta nimiä vuosisetin mukaan). Palaa kohtaan #luodaan_murtoviivat ja toista sama muilla vuosiseteillä
    Luo taulukko.

######################

PREDICTION PLOT ja taulukko Hpool-tapauksessa:

Jos haluat tehdä edellisen murtoviivakuvaajan total_SOC sijaan Hpool:eilla, käytä tiedostoa 
R script: Multiennuste_automatisointi_Hpool.R.

Prediction plot vaiheiden 1 - 3.1 aikana tallennettiin myös humuksen kehitys (10obsrun_*H.dat) arvot jokaiselle vuodelle. (* = 5,10 tai 15 init-hetkestä riippuen)
Kohdasta 3.2 eteenpäin käytä skriptiä Multiennuste_automatisointi_Hpool.R, jossa tiedostonimet on muutettu vastaamaan humusta.

######################
