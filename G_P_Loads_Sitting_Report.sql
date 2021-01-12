select top 1000
[Trl] = trl_number,
--[Type1] = trl_type1,
[Type] = name,
[PC#] = trl_branch,
--trl_terminal,
[Sts] = trl_status,
[TrlSchDate] = CONVERT(VARCHAR(20),trl_sch_date,120),
[DestCmp] = trl_sch_cmp_id,
[DestCty] = c2.cty_nmstct,
[SchSts] = trl_sch_status,
[TrlAvailDate] = CONVERT(VARCHAR(20),trl_avail_date,120),
[NextAvailCmp] = trl_avail_cmp_id,
[NextAvailCity] = c3.cty_nmstct,
[LastEvent] = trl_prior_event,
[PriorCmp] = trl_prior_cmp_id,
[PriorCity] = c1.cty_nmstct,
[LegEndDate] = lh.LegEndDate,
[CurrentTime] = GETDATE(),

--[DwellDays] = DATEDIFF(day, lh.LegEndDate, GETDATE()) ,
--[DwellHours] = DATEDIFF(hour, lh.LegEndDate, GETDATE()),
[DwellMins] = DATEDIFF(minute, lh.LegEndDate, GETDATE())


FROM trailerprofile
LEFT JOIN (SELECT labeldefinition,
	abbr,
	name,
	userlabelname
	FROM labelfile 
	WHERE labeldefinition = 'TrlType1'
) l ON l.abbr = trailerprofile.trl_type1
LEFT JOIN city c1 on trl_prior_city = c1.cty_code
LEFT JOIN city c2 on trl_sch_city = c2.cty_code
LEFT JOIN city c3 on trl_avail_city = c3.cty_code
LEFT JOIN (select lgh_primary_trailer,
			MAX(lgh_enddate) AS LegEndDate
			FROM legheader LEFT JOIN trailerprofile ON trl_number = lgh_primary_trailer
			WHERE lgh_outstatus = 'CMP'
			/*
			AND (trailerprofile.trl_branch IN ('570','571','572','573','574','580','581','586')
			OR cmp_id_end IN ('GPCOSC',
								'GPATGA',
								'GPGRSC',
								'GPNASC',
								'GPANSC',
								'GPCHSC',
								'GPDYCH',
								'GPCLNC',
								'GPFLSC',
								'GPSAGA',
								'GPCCHA',
								'GPCHTN',
								'GPHALA',
								'GPLATX')
								)*/
			group by lgh_primary_trailer) lh ON lh.lgh_primary_trailer = trl_number
WHERE
trl_prior_event = 'DLT'
--and trl_prior_cmp_id = 'GPGRSC'
AND (trailerprofile.trl_terminal IN ('570','571','572','573','574','580','581','586')
OR trl_prior_cmp_id IN ('GPCOSC',
						'GPATGA',
						'GPGRSC',
						'GPNASC',
						'GPANSC',
						'GPCHSC',
						'GPDYCH',
						'GPCLNC',
						'GPFLSC',
						'GPSAGA',
						'GPCCHA',
						'GPCHTN',
						'GPHALA',
						'GPLATX'))
AND trl_status NOT IN ('OUT','AVL')
--and trl_number <> 'B5013'
AND trl_number NOT LIKE '%DUM%'
ORDER BY c1.cty_nmstct,trl_prior_cmp_id,trl_sch_date ASC