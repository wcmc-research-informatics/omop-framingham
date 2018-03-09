--unpivot to EAV store
use omop_framingham
select u.[pid] as PID, u.val as [val], details as [CODE] 
into framingham_pivoted
from framingham_raw s
unpivot
(
val for details in (
[FC2],
[FC3],
[FC6],
[FC7],
[FC79],
[FC191],
[FC192],
[FC193],
[FC194],
[FC197],
[FC198],
[FC200],
[FC201],
[FC222],
[FC219],
[FC220],
[FC210],
[FC215],
[FC216],
[FC217],
[FC218]
)
) u
 
 --check domains
with t as (
select piv.*, c.* from framingham_pivoted piv
join framingham_mapping fm on fm.CODE = piv.CODE
left join FULL_OMOP.dbo.CONCEPT c on c.CONCEPT_ID = fm.target_concept_id
)
select distinct domain_id from t

--build condition_occurrence
select 
ABS(CHECKSUM(NEWID())) as condition_occurrence_id,
pid as person_id,
fm.target_concept_id as condition_concept_id,
'45905770' as condition_type_concept_id,
null as condition_start_date,
null as condition_end_date,
null as stop_reason,
null as provider_id,
'0000001' as visit_occurrence_id,
fp.CODE as condition_source_value,
null as condition_source_concept_id
--into omop_framingham.dbo.condition_occurrence
from framingham_pivoted fp
join framingham_mapping fm on fm.code = fp.CODE
join FULL_OMOP.dbo.concept c on c.CONCEPT_ID = fm.target_concept_id
where c.DOMAIN_ID = 'Condition'
and val != '0'

