// =====================================================
// 프린팅 부품 단품 배치 — STL 내보내기 / 슬라이싱용
//
// 사용:
//   openscad -o base.stl  -D 'part="base"'  scad/print_parts.scad
//   openscad -o hub.stl   -D 'part="hub"'   scad/print_parts.scad
//   openscad -o ring.stl  -D 'part="ring"'  scad/print_parts.scad
//   part="all" 이면 베드 배치로 한꺼번에 보기
//
// 프린팅 방향 (전 부품 서포트 불필요):
//   base — 윗면을 베드에 (잭 블록·웨이스트 리브가 위로, 트렌치는 3.5mm 브리지,
//          잭 너트 포켓은 꼭짓점-업 육각이라 60° 벽으로 출력됨)
//   hub  — 암 윗면을 베드에 (플랜지는 1.3mm 단차 지붕으로 받쳐져 서포트 프리,
//          베어링 단턱은 1mm 이하 링 브리지)
//   ring — 너트 포켓이 위로 (평면 부품)
// =====================================================

include <params.scad>
include <motor_side.scad>
include <output_side.scad>

part = "all";

module print_base() { rotate([180, 0, 0]) base_plate(); }                  // 윗면이 베드
module print_hub()  { translate([0, 0, arm_z1]) rotate([180, 0, 0]) arm_hub(); }
module print_ring() { translate([0, 0, -clamp_ring_z0]) clamp_ring(); }
// axle="printed" 변형 전용 슬리브 2종 (수직 출력, 서포트 불필요)
module print_sleeves() {
    printed_standoff_sleeve();
    translate([20, 0, -(lower_brg_z0 + brg_w)]) printed_inner_sleeve();
}

if (part == "base") print_base();
if (part == "hub")  print_hub();
if (part == "ring") print_ring();
if (part == "sleeves") print_sleeves();
if (part == "all") {
    print_base();
    translate([60, 70, 0]) print_hub();
    translate([-60, 70, 0]) print_ring();
    if (axle == "printed") translate([-100, 30, 0]) print_sleeves();
}
