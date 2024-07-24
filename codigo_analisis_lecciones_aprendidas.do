*Código para replicar los análisis del documento:
*Avenburg, A.; Park, L.; Trombetta, M.; Migliore, M. y Poy, S. (2024). Lecciones aprendidas y desafíos actuales de los programas de empleo: Un análisis de Potenciar Trabajo en CABA. Fundar.

*INSTALAMOS PAQUETE ESTOUT
ssc install estout, replace

*CREAMOS VARIABLES
gen psh=p1==1
gen mujer=p2==1
gen 	edadt=.
replace edadt=1 if (p3<25)
replace edadt=2 if (p3>=25 & p3<45)
replace edadt=3 if (p3>=45 & p3!=.)
gen 	estudios_V2=.
replace estudios_V2=1 if inlist(p4,1,2,3)
replace estudios_V2=2 if inlist(p4,4)
replace estudios_V2=3 if inlist(p4,5)
replace estudios_V2=4 if inlist(p4,6)
replace estudios_V2=5 if inlist(p4,7)
gen 	estudios_V3=.
replace estudios_V3=1 if inlist(p4,1,2,3,4)
replace estudios_V3=2 if inlist(p4,5)
replace estudios_V3=3 if inlist(p4,6)
replace estudios_V3=4 if inlist(p4,7)
gen barrio_popular=tipo_de_barrio==1
gen no_nacio_en_Argentina=inlist(p12,5,6)
gen microempresa=inlist(p18,1,2) if p18!=.
encode p20c_renatep_rama_etiqueta, generate(rama)
gen blanco=p25==1 if p25!=.
gen oficio=inlist(p52,1) if p52!=.
gen cursos=inlist(p65,1)|inlist(p66,1,2,3,4) if (p65!=.|p66!=.)

*CREAMOS MAS VARIABLES
gen potenciar=p61==1
gen 	contra=.
replace contra=1 if potenciar==1 & p62==1
replace contra=2 if potenciar==1 & p62==2
replace contra=3 if potenciar==1 & p62==3 & inlist(p63,1,2,3)
replace contra=4 if potenciar==1 & p62==3 & inlist(p63,4,9)
gen contra_ning=contra==4 if potenciar==1
gen 	pluri=.
replace pluri=0 if p16==1 | (p16==. & potenciar==1 & contra==1)
replace pluri=1 if p16==2 | p16==3 | (potenciar==1 & contra==2)
gen habit_hor_imp=inlist(p36,1,2) if p36!=.
gen habit_tar_tie=inlist(p37,1,2) if p37!=.
foreach i in p38 p38_1 p38_2 p38_3 p38_4 p38_5 {
	gen `i'_ok=`i'==3 if `i'!=.
}
gen potenciar_ocprin=contra==1

*TABLA A1
eststo     PT: reg potenciar   mujer psh ib2.edadt barrio_popular ib3.estudios_V2 no_nacio_en_Argentina, robust
eststo contra: reg contra_ning mujer psh ib2.edadt barrio_popular ib3.estudios_V2 no_nacio_en_Argentina, robust
est table PT contra, star(0.1 0.05 0.01) stats(N r2) drop(_cons) b(%9.4f) varwidth(40)

*TABLA A2
eststo habit_horas : reg habit_hor_imp mujer psh ib2.edadt barrio_popular ib3.estudios_V2 no_nacio_en_Argentina potenciar pluri, robust
eststo habit_tareas: reg habit_tar_tie mujer psh ib2.edadt barrio_popular ib3.estudios_V2 no_nacio_en_Argentina potenciar pluri, robust
est table habit_horas habit_tareas, star(0.1 0.05 0.01) stats(N r2) drop(_cons) b(%9.4f) varwidth(40)

*TABLA A3
foreach i in p38 p38_1 p38_2 p38_3 p38_4 p38_5 {
	eststo satisf_`i': reg `i'_ok mujer psh ib2.edadt barrio_popular ib3.estudios_V2 no_nacio_en_Argentina i.potenciar_ocprin, robust
}
est table satisf_*, star(0.1 0.05 0.01) stats(N r2) drop(_cons) b(%9.4f) varwidth(40)

*TABLA A4
eststo a4_1: reg blanco i.estudios_V3        mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a4_2: reg blanco               cursos mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a4_3: reg blanco i.estudios_V3 cursos mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a4_4: reg blanco i.estudios_V3 cursos mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa ib2.rama if rama!=1, vce(r)
est table a4_1 a4_2 a4_3 a4_4, star(0.1 0.05 0.01) stats(N r2) b(%9.4f) varwidth(40)

*TABLA A5
eststo a5_1: reg blanco i.estudios_V3        mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a5_2: reg blanco               oficio mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a5_3: reg blanco i.estudios_V3 oficio mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a5_4: reg blanco i.estudios_V3 oficio mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa ib2.rama if rama!=1, vce(r)
est table a5_1 a5_2 a5_3 a5_4, star(0.1 0.05 0.01) stats(N r2) b(%9.4f) varwidth(40)

*TABLA A6
eststo a6_1: reg blanco ib99.p67_tema_curso_grupos, vce(r)
eststo a6_2: reg blanco ib99.p67_tema_curso_grupos i.estudios_V3 mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
eststo a6_3: reg blanco ib99.p67_tema_curso_grupos i.estudios_V3 mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa ib2.rama if rama!=1, vce(r)
est table a6_1 a6_2 a6_3, star(0.1 0.05 0.01) stats(N r2) b(%9.4f) varwidth(40)

*GRÁFICO 14
reg blanco i.estudios_V3 mujer psh ib2.edadt barrio_popular no_nacio_en_Argentina microempresa, vce(r)
margins, dydx(*) post 
marginsplot, horizontal xline(0) yscale(reverse) recast(scatter) derivlabels xtitle("Efecto sobre la probabilidad de tener un empleo formal") ytitle("Variables explicativas") title("")
