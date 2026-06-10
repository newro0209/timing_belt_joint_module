// =====================================================
// 프린팅 부품 단품 배치 — STL 내보내기 / 슬라이싱용
//
// 사용:
//   openscad -o base.stl  -D 'part="base"'  scad/print_parts.scad
//   openscad -o hub.stl   -D 'part="hub"'   scad/print_parts.scad
//   openscad -o ring.stl  -D 'part="ring"'  scad/print_parts.scad
//   part="all" 이면 베드 배치로 한꺼번에 보기
//
// 프린팅 방향:
//   base — 윗면을 베드에 (잭 블록이 위로 향해 서포트 불필요)
//   hub  — 암 윗면을 베드에 (베어링 보어 수직, 플랜지 로브 아래만 소량 서포트)
//   ring — 너트 포켓이 위로 (그대로)
// =====================================================

include <params.scad>
include <motor_side.scad>
include <output_side.scad>

part = "all";

module print_base() { rotate([180, 0, 0]) base_plate(); }                  // 윗면이 베드
module print_hub()  { translate([0, 0, arm_z1]) rotate([180, 0, 0]) arm_hub(); }
module print_ring() { translate([0, 0, -clamp_ring_z0]) clamp_ring(); }

if (part == "base") print_base();
if (part == "hub")  print_hub();
if (part == "ring") print_ring();
if (part == "all") {
    print_base();
    translate([60, 70, 0]) print_hub();
    translate([-60, 70, 0]) print_ring();
}
