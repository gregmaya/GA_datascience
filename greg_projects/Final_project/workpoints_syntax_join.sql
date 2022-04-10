Alter table wenlock_ml.manual_workpoints
add acc_syntax_refs varchar,
add acc_area float,
add acc_compactness float,
add acc_drift float,
add acc_occlusivity float,
add acc_vista float,
add acc_perimeter float,
add acc_variance float,
add acc_skewness float,
add acc_avgradial float,
add acc_control float,
add acc_controllability float,
add acc_mmd float,
add acc_mvd float,
add acc_mad float,
add acc_integration float;
Update wenlock_ml.manual_workpoints wk set
      acc_syntax_refs = subset.syntax_refs,
      acc_area = subset.area,
      acc_compactness = subset.compactness,
      acc_drift = subset.drift,
      acc_occlusivity = subset.occlusivity,
      acc_vista = subset.vista,
      acc_perimeter = subset.perimeter,
      acc_variance = subset.variance,
      acc_skewness = subset.skewness,
      acc_avgradial = subset.avgradial,
      acc_control = subset.control,
      acc_controllability = subset.controllability,
      acc_mmd = subset.mmd,
      acc_mvd = subset.mvd,
      acc_mad = subset.mad,
      acc_integration = subset.integration
from (select wk.workpoint_id,
            array_agg(sx.ref) as syntax_refs,
            avg(sx.area) as area,
            avg(sx.compactness) compactness,
            avg(sx.drift) drift,
            avg(sx.occlusivity) occlusivity,
            avg(sx.vista) vista,
            avg(sx.perimeter) perimeter,
            avg(sx.variance) variance,
            avg(sx.skewness) skewness,
            avg(sx."average radial") avgradial,
            avg(sx.control) control,
            avg(sx.controllability) controllability,
            avg(sx."mean metric depth") mmd,
            avg(sx."mean visual depth") mvd,
            avg(sx."mean angular depth") mad,
            avg(sx."integration (hh)") integration
            from wenlock_ml.manual_workpoints as wk
            JOIN wenlock_ml.syntax_acc as sx
            on st_dwithin(sx.geom, wk.geom, 0.3)
            group by wk.workpoint_id ) subset
where wk.workpoint_id = subset.workpoint_id;

--- aggregating point depths from the entrance
Alter table wenlock_ml.manual_workpoints
add pd_acc_entrance integer,
add pd_acc_teapoint integer;

update wenlock_ml.manual_workpoints as wk set
  pd_acc_entrance = subset.pd_acc_entrance,
  pd_acc_teapoint = subset.pd_acc_teapoint

  from (select wk.workpoint_id,
              min(sxpd.pd_acc_entrance) as pd_acc_entrance,
              min(sxpd.pd_acc_teapoint) as pd_acc_teapoint
        from wenlock_ml.manual_workpoints as wk
        join wenlock_ml.syntax_acc_pd as sxpd
        on st_dwithin(sxpd.geom, wk.geom, 0.3)
        group by wk.workpoint_id) subset
where wk.workpoint_id = subset.workpoint_id;
