include <params.scad>

// =====================================================
// 출력축 부품 — 스트리퍼 볼트(머리 하향) + 608ZZ x2 + 암 허브 + GT2 60T 풀리
// 모든 모듈은 전역 좌표계에 배치된 상태로 그려짐
// (베이스 윗면 z=0, 출력축 중심 (0,0), 암은 +x 방향)
// 모듈 정의만 있음 — 호출은 assembly.scad에서.
//
// 적층 (아래→위):
//   머리 Ø13 / M8와셔(베이스 아래) / 베이스 8
//   / 스케이트 스페이서 10+10 / 하부 608ZZ 7 / 스케이트 스페이서 10
//   / 상부 608ZZ 7 / 심와셔 0.7 / M8와셔 1.6 / M6 나일록 너트
//   쇼울더 Ø8 L55: z -9.6 .. 45.4, M6 나사부 45.4 .. 55.4
// =====================================================

eps = 0.01;

// ---------------------------------------------------
// 1. 스트리퍼 볼트 (쇼울더 Ø8 L55 + M6x10, 머리 하향)
// ---------------------------------------------------
module stripper_bolt() {
    color(c_steel) {
        difference() {
            union() {
                // 머리 (베이스 아래, 와셔 밑)
                translate([0, 0, shoulder_z0 - bolt_head_h])
                    cylinder(d = bolt_head_d, h = bolt_head_h);
                // Ø8 쇼울더부
                translate([0, 0, shoulder_z0])
                    cylinder(d = 8, h = shoulder_l);
                // M6 나사부 (위쪽 끝)
                translate([0, 0, shoulder_z1])
                    cylinder(d = 6, h = m6_thread_l);
            }
            // 육각 소켓 자국 (머리 아랫면)
            translate([0, 0, shoulder_z0 - bolt_head_h - eps])
                cylinder($fn = 6, d = 6, h = 3 + eps);
        }
    }
}

// ---------------------------------------------------
// 2. 608ZZ 베어링 (z0에서 시작)
//    내륜 외경 ~12.4 / 외륜 내경 ~17.8 (실물 근사)
// ---------------------------------------------------
module bearing_608(z0) {
    translate([0, 0, z0]) {
        // 외륜 Ø22..Ø17.8
        color(c_steel)
            difference() {
                cylinder(d = brg_od, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = 17.8, h = brg_w + 2*eps);
            }
        // 내륜 Ø12.4..Ø8
        color(c_steel)
            difference() {
                cylinder(d = 12.4, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = brg_id, h = brg_w + 2*eps);
            }
        // 실드 (폭 중앙부)
        color([0.55, 0.55, 0.58])
            translate([0, 0, brg_w/2 - 2])
                difference() {
                    cylinder(d = 17.8, h = 4);
                    translate([0, 0, -eps]) cylinder(d = 12.4, h = 4 + 2*eps);
                }
    }
}

// ---------------------------------------------------
// 3. 스케이트 스페이서 8x10x10 (범용)
// ---------------------------------------------------
module skate_spacer(z0) {
    color(c_alu)
        translate([0, 0, z0])
            difference() {
                cylinder(d = skate_od, h = skate_l);
                translate([0, 0, -eps]) cylinder(d = 8.2, h = skate_l + 2*eps);
            }
}

// 내륜 스페이서 (베어링 사이, z 27..37)
module inner_spacer()    { skate_spacer(lower_brg_z0 + brg_w); }
// 스탠드오프 스페이서 2개 (베이스 위, z 0..20)
module standoff_spacer() { skate_spacer(0); skate_spacer(skate_l); }

// ---------------------------------------------------
// 4. 심 와셔 (z 44..44.7, 0.5+0.2 조합 예시)
// ---------------------------------------------------
module shim_washer() {
    color(c_alu)
        translate([0, 0, stack_top])
            difference() {
                cylinder(d = 14, h = shim_t);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = shim_t + 2*eps);
            }
}

// ---------------------------------------------------
// 5. 상부 M8 평와셔 (z 44.7..46.3) — 외륜 Ø17.8에 닿지 않음
//    쇼울더 끝(45.4)을 와셔 두께 안에 품어 너트가 적층을 압축
// ---------------------------------------------------
module top_washer() {
    color(c_steel)
        translate([0, 0, stack_top + shim_t])
            difference() {
                cylinder(d = washer_od, h = top_washer_t);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = top_washer_t + 2*eps);
            }
}

// ---------------------------------------------------
// 6. 머리측 M8 평와셔 (베이스 아래 z -9.6..-8)
// ---------------------------------------------------
module head_washer() {
    color(c_steel)
        translate([0, 0, shoulder_z0])
            difference() {
                cylinder(d = washer_od, h = head_washer_t);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = head_washer_t + 2*eps);
            }
}

// ---------------------------------------------------
// 7. 암 허브 + 암 (프린팅)
//    하면(16.2)에 풀리 상부 플랜지 받이 포켓 Ø44.6x1 — 풀리 센터링
//    베어링 보어: 하부는 아래로, 상부는 위로 개방 (압입 가능)
// ---------------------------------------------------
module arm_hub() {
    color(c_print)
        difference() {
            union() {
                // 허브 본체
                translate([0, 0, hub_z0])
                    cylinder(d = hub_od, h = hub_z1 - hub_z0);
                // 클램프 플랜지 (허브 하단 일체, 두께 4)
                translate([0, 0, hub_z0])
                    cylinder(d = hub_flange_od, h = hub_flange_t);
                // 암 (+x 방향, 끝 둥글게)
                translate([0, 0, arm_z0])
                    linear_extrude(height = arm_z1 - arm_z0)
                        hull() {
                            circle(d = hub_od);
                            translate([arm_len, 0]) circle(d = arm_w);
                        }
            }
            // 풀리 받이 포켓 (하면, 상부 플랜지 Ø44 센터링)
            translate([0, 0, hub_z0 - eps])
                cylinder(d = hub_recess_d, h = hub_recess_h + eps);
            // 하부 베어링 보어 (하면에서 개방, 단턱 z 27)
            translate([0, 0, hub_z0 - eps])
                cylinder(d = brg_od + 0.1,
                         h = (lower_brg_z0 + brg_w) - hub_z0 + eps);
            // 중앙 웹 내경 Ø20 (z 27..37)
            translate([0, 0, lower_brg_z0 + brg_w - eps])
                cylinder(d = 20, h = spacer_h + 2*eps);
            // 상부 베어링 보어 (윗면까지 개방, 단턱 z 37)
            translate([0, 0, upper_brg_z0 - eps])
                cylinder(d = brg_od + 0.1, h = hub_z1 - upper_brg_z0 + 2*eps);
            // 클램프 볼트 M3 관통홀 Ø3.4 — 플랜지 관통
            for (a = clamp_bolt_angles)
                rotate([0, 0, a])
                    translate([clamp_pcd/2, 0, hub_z0 - 1])
                        cylinder(d = 3.4, h = hub_flange_t + 2);
            // 암 끝 Ø8 구멍 (다음 관절용)
            translate([arm_len, 0, arm_z0 - eps])
                cylinder(d = 8, h = (arm_z1 - arm_z0) + 2*eps);
        }
}

// ---------------------------------------------------
// 8. GT2 60T 출력 풀리 (12mm bore, 세트스크류 보스 하향)
// ---------------------------------------------------
module pulley60() {
    color(c_alu)
        difference() {
            union() {
                // 세트스크류 보스 (아래 — 클램프 링 내경 안)
                translate([0, 0, p60_z0])
                    cylinder(d = p60_boss_d, h = p60_boss_h);
                // 아래 플랜지
                translate([0, 0, p60_fl1_z0])
                    cylinder(d = p60_flange_d, h = p60_flange_t);
                // 이빨부(원통 단순화)
                translate([0, 0, p60_teeth_z0])
                    cylinder(d = p60_od, h = p60_teeth_h);
                // 위 플랜지 (허브 포켓에 들어감)
                translate([0, 0, p60_z1 - p60_flange_t])
                    cylinder(d = p60_flange_d, h = p60_flange_t);
            }
            // 보어 Ø12 (Ø8 축 + OD10 스페이서 클리어런스)
            translate([0, 0, p60_z0 - eps])
                cylinder(d = p60_bore, h = (p60_z1 - p60_z0) + 2*eps);
            // 세트스크류 구멍 자국 (보스 측면 — 스크류는 제거 상태)
            for (a = [0, 90])
                rotate([0, 0, a])
                    translate([p60_bore/2, 0, p60_z0 + p60_boss_h/2])
                        rotate([0, 90, 0])
                            cylinder(d = 3, h = (p60_boss_d - p60_bore)/2 + eps);
        }
}

// ---------------------------------------------------
// 9. 클램프 링 (프린팅) — 풀리 하부 플랜지를 아래에서 받침
//    너트 포켓은 윗면(중력으로 너트 유지, 조립 편의)
// ---------------------------------------------------
module clamp_ring() {
    color(c_print2)
        difference() {
            translate([0, 0, clamp_ring_z0])
                cylinder(d = clamp_ring_od, h = clamp_ring_z1 - clamp_ring_z0);
            // 내경 (풀리 보스 Ø32 회피)
            translate([0, 0, clamp_ring_z0 - eps])
                cylinder(d = clamp_ring_id,
                         h = (clamp_ring_z1 - clamp_ring_z0) + 2*eps);
            // M3 관통 + 윗면 육각 너트 포켓
            for (a = clamp_bolt_angles)
                rotate([0, 0, a])
                    translate([clamp_pcd/2, 0, 0]) {
                        translate([0, 0, clamp_ring_z0 - eps])
                            cylinder(d = 3.4,
                                     h = (clamp_ring_z1 - clamp_ring_z0) + 2*eps);
                        // 너트 포켓 (폭간 5.8, 깊이 2.5, 윗면에서)
                        translate([0, 0, clamp_ring_z1 - 2.5])
                            cylinder($fn = 6, d = 5.8 / cos(30), h = 2.5 + eps);
                    }
        }
}

// ---------------------------------------------------
// 10. M3x16 클램프 볼트 3개 + 너트 (포켓 안)
// ---------------------------------------------------
module pulley_bolts() {
    color(c_steel)
        for (a = clamp_bolt_angles)
            rotate([0, 0, a])
                translate([clamp_pcd/2, 0, 0]) {
                    // 머리 Ø5.5 x 3 (허브 플랜지 윗면 위)
                    translate([0, 0, hub_flange_z1])
                        cylinder(d = 5.5, h = 3);
                    // 축 Ø3 (M3x16: 플랜지 → 클램프 링 너트)
                    translate([0, 0, hub_flange_z1 - 16])
                        cylinder(d = 3, h = 16);
                    // 육각 너트 (클램프 링 윗면 포켓 안, 폭간 5.5 x 2.4)
                    translate([0, 0, clamp_ring_z1 - 2.45])
                        cylinder($fn = 6, d = 5.5 / cos(30), h = 2.4);
                }
}

// ---------------------------------------------------
// 11. M6 나일록 너트 (적층 상단 체결)
// ---------------------------------------------------
module m6_top_nut() {
    nut_z0 = stack_top + shim_t + top_washer_t;   // 46.3
    color(c_steel) {
        translate([0, 0, nut_z0])
            cylinder($fn = 6, d = nut_m6_af / cos(30), h = nut_m6_h);
        // 나일론 캡 (원통 1mm, 너트 위쪽 끝)
        translate([0, 0, nut_z0 + nut_m6_h])
            cylinder(d = 9, h = 1);
    }
}
