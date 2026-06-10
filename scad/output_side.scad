include <params.scad>

// =====================================================
// 출력축 부품 — 스트리퍼 볼트 + 608ZZ x2 + 암 허브 + GT2 60T 풀리
// 모든 모듈은 전역 좌표계에 배치된 상태로 그려짐
// (베이스 윗면 z=0, 출력축 중심 (0,0), 암은 +x 방향)
// 모듈 정의만 있음 — 호출은 assembly.scad에서.
// =====================================================

eps = 0.01;

// 적층 기준 z (params 유도값)
osb_shoulder_top = shoulder_top + shim_t + top_washer_t;   // 26.4 : 쇼울더부 끝 = 볼트 머리 자리면

// ---------------------------------------------------
// 1. 스트리퍼 볼트 (쇼울더 Ø8 L25 상당 + M6 나사부)
// ---------------------------------------------------
module stripper_bolt() {
    color(c_steel) {
        difference() {
            union() {
                // Ø8 쇼울더부 (z 0 부근 .. 26.4)
                translate([0, 0, -0.5])
                    cylinder(d = 8, h = osb_shoulder_top + 0.5);
                // 머리
                translate([0, 0, osb_shoulder_top])
                    cylinder(d = bolt_head_d, h = bolt_head_h);
                // M6 나사부 (베이스 관통 + 아래로 6mm)
                translate([0, 0, -base_t - 6])
                    cylinder(d = 6, h = base_t + 6);
            }
            // 육각 소켓 자국 (머리 윗면, Ø6 x 3)
            translate([0, 0, osb_shoulder_top + bolt_head_h - 3])
                cylinder($fn = 6, d = 6, h = 3 + eps);
        }
    }
}

// ---------------------------------------------------
// 2. 608ZZ 베어링 (z0에서 시작)
// ---------------------------------------------------
module bearing_608(z0) {
    translate([0, 0, z0]) {
        // 외륜 Ø22..Ø18.5
        color(c_steel)
            difference() {
                cylinder(d = brg_od, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = 18.5, h = brg_w + 2*eps);
            }
        // 내륜 Ø11.5..Ø8
        color(c_steel)
            difference() {
                cylinder(d = 11.5, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = brg_id, h = brg_w + 2*eps);
            }
        // 실드 (폭 중앙부)
        color([0.55, 0.55, 0.58])
            translate([0, 0, brg_w/2 - 2])
                difference() {
                    cylinder(d = 18.5, h = 4);
                    translate([0, 0, -eps]) cylinder(d = 11.5, h = 4 + 2*eps);
                }
    }
}

// ---------------------------------------------------
// 3. 내륜 스페이서 (z 10..18)
// ---------------------------------------------------
module inner_spacer() {
    color(c_alu)
        translate([0, 0, lower_brg_z0 + brg_w])
            difference() {
                cylinder(d = spacer_od, h = spacer_h);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = spacer_h + 2*eps);
            }
}

// ---------------------------------------------------
// 4. 스탠드오프 스페이서 (z 0..3)
// ---------------------------------------------------
module standoff_spacer() {
    color(c_alu)
        difference() {
            cylinder(d = spacer_od, h = standoff_h);
            translate([0, 0, -eps]) cylinder(d = 8.4, h = standoff_h + 2*eps);
        }
}

// ---------------------------------------------------
// 5. 심 와셔 (z 25..25.2)
// ---------------------------------------------------
module shim_washer() {
    color(c_alu)
        translate([0, 0, shoulder_top])
            difference() {
                cylinder(d = 14, h = shim_t);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = shim_t + 2*eps);
            }
}

// ---------------------------------------------------
// 6. 상부 와셔 (z 25.2..26.4) — 외륜 Ø22에 닿지 않음
// ---------------------------------------------------
module top_washer() {
    color(c_steel)
        translate([0, 0, shoulder_top + shim_t])
            difference() {
                cylinder(d = 16, h = top_washer_t);
                translate([0, 0, -eps]) cylinder(d = 8.4, h = top_washer_t + 2*eps);
            }
}

// ---------------------------------------------------
// 7. 암 허브 + 암 (프린팅)
// ---------------------------------------------------
module arm_hub() {
    color(c_print)
        difference() {
            union() {
                // 허브 본체
                translate([0, 0, hub_z0])
                    cylinder(d = hub_od, h = hub_z1 - hub_z0);
                // 클램프 플랜지 (일체)
                translate([0, 0, hub_flange_z0])
                    cylinder(d = hub_flange_od, h = hub_flange_z1 - hub_flange_z0);
                // 암 (+x 방향, 끝 둥글게)
                translate([0, 0, arm_z0])
                    linear_extrude(height = arm_z1 - arm_z0)
                        hull() {
                            circle(d = hub_od);
                            translate([arm_len, 0]) circle(d = arm_w);
                        }
            }
            // 베어링 보어 (하부 z 3..10, 상부 z 18..25)
            translate([0, 0, lower_brg_z0 - eps])
                cylinder(d = brg_od + 0.1, h = brg_w + 2*eps);
            translate([0, 0, upper_brg_z0 - eps])
                cylinder(d = brg_od + 0.1, h = brg_w + 2*eps);
            // 단턱 내경 Ø20 (z 10..18)
            translate([0, 0, lower_brg_z0 + brg_w - eps])
                cylinder(d = 20, h = spacer_h + 2*eps);
            // 허브 위쪽 립 내경 Ø20 (z 25..26)
            translate([0, 0, shoulder_top - eps])
                cylinder(d = 20, h = hub_z1 - shoulder_top + 2*eps);
            // 클램프 볼트 M3 구멍 (Ø2.8) — 플랜지 관통
            for (a = clamp_bolt_angles)
                rotate([0, 0, a])
                    translate([clamp_pcd/2, 0, hub_flange_z0 - 5])
                        cylinder(d = 2.8, h = (hub_flange_z1 - hub_flange_z0) + 10);
            // 암 끝 Ø8 구멍 (다음 관절용)
            translate([arm_len, 0, arm_z0 - eps])
                cylinder(d = 8, h = (arm_z1 - arm_z0) + 2*eps);
        }
}

// ---------------------------------------------------
// 8. GT2 60T 출력 풀리
// ---------------------------------------------------
module pulley60() {
    color(c_alu)
        difference() {
            union() {
                // 이빨부(원통 단순화) 본체
                translate([0, 0, p60_z0])
                    cylinder(d = p60_od, h = p60_z1 - p60_z0);
                // 아래 플랜지
                translate([0, 0, p60_z0])
                    cylinder(d = p60_flange_d, h = 0.6);
                // 위 플랜지
                translate([0, 0, p60_z1 - 0.6])
                    cylinder(d = p60_flange_d, h = 0.6);
            }
            // 보어
            translate([0, 0, p60_z0 - eps])
                cylinder(d = p60_bore, h = (p60_z1 - p60_z0) + 2*eps);
        }
}

// ---------------------------------------------------
// 9. 클램프 링 (프린팅)
// ---------------------------------------------------
module clamp_ring() {
    color(c_print2)
        difference() {
            translate([0, 0, clamp_ring_z0])
                cylinder(d = clamp_ring_od, h = clamp_ring_z1 - clamp_ring_z0);
            // 내경
            translate([0, 0, clamp_ring_z0 - eps])
                cylinder(d = clamp_ring_id, h = (clamp_ring_z1 - clamp_ring_z0) + 2*eps);
            // M3 관통 + 아랫면 육각 너트 포켓
            for (a = clamp_bolt_angles)
                rotate([0, 0, a])
                    translate([clamp_pcd/2, 0, 0]) {
                        translate([0, 0, clamp_ring_z0 - eps])
                            cylinder(d = 3.4, h = (clamp_ring_z1 - clamp_ring_z0) + 2*eps);
                        // 너트 포켓 (폭간 5.7, 깊이 2.5, 아랫면에서)
                        translate([0, 0, clamp_ring_z0 - eps])
                            cylinder($fn = 6, d = 5.7 / cos(30), h = 2.5 + eps);
                    }
        }
}

// ---------------------------------------------------
// 10. M3x12 클램프 볼트 3개 + 너트
// ---------------------------------------------------
module pulley_bolts() {
    color(c_steel)
        for (a = clamp_bolt_angles)
            rotate([0, 0, a])
                translate([clamp_pcd/2, 0, 0]) {
                    // 머리 Ø5.5 x 3 (허브 플랜지 윗면 위)
                    translate([0, 0, hub_flange_z1])
                        cylinder(d = 5.5, h = 3);
                    // 축 Ø3 (M3x12: 플랜지 + 클램프 링 관통)
                    translate([0, 0, hub_flange_z1 - 12])
                        cylinder(d = 3, h = 12);
                    // 육각 너트 (클램프 링 포켓 위치, 폭간 5.5 x 2.4)
                    translate([0, 0, clamp_ring_z0 + 0.05])
                        cylinder($fn = 6, d = 5.5 / cos(30), h = 2.4);
                }
}

// ---------------------------------------------------
// 11. M3 히트세트 인서트 3개 (허브 플랜지 안)
// ---------------------------------------------------
module heat_inserts() {
    color(c_brass)
        for (a = clamp_bolt_angles)
            rotate([0, 0, a])
                translate([clamp_pcd/2, 0, hub_flange_z1 - 4])
                    difference() {
                        cylinder(d = 4.6, h = 4);
                        translate([0, 0, -eps]) cylinder(d = 3, h = 4 + 2*eps);
                    }
}

// ---------------------------------------------------
// 12. M6 와셔 + 나일록 너트 (베이스 하면 아래)
// ---------------------------------------------------
module m6_fastener() {
    color(c_steel) {
        // 대형 와셔 Ø16 x 1.6
        translate([0, 0, -base_t - 1.6])
            difference() {
                cylinder(d = 16, h = 1.6);
                translate([0, 0, -eps]) cylinder(d = 6.4, h = 1.6 + 2*eps);
            }
        // 나일록 너트 (육각 폭간 10, 높이 5)
        translate([0, 0, -base_t - 1.6 - 5])
            cylinder($fn = 6, d = 10 / cos(30), h = 5);
        // 나일론 캡 (원통 1mm, 너트 아래쪽 끝)
        translate([0, 0, -base_t - 1.6 - 5 - 1])
            cylinder(d = 9, h = 1);
    }
}
