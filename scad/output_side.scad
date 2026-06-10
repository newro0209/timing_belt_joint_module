include <params.scad>

// =====================================================
// 출력축 부품 — 회전축 구조
// 스트리퍼 볼트(머리 하향)가 회전축. 베어링은 베이스 일체 하향
// 보스에 들어가고(외륜 고정), 볼트+내륜+풀리+허브가 M6 너트
// 축력으로 한 덩어리로 클램프되어 함께 회전한다.
//
// 회전 적층 (아래→위):
//   머리(-31.1) / M8와셔 / 하부 608 내륜(-24..-17) / 스페이서 10
//   / 상부 608 내륜(-7..0) / M8와셔 / 풀리(1.6..17.3, 보스 하향 8mm bore)
//   / 허브(17.3..30.3) / M6 광폭와셔 22×2.0 / M6 나일록(32.3..)
//   쇼울더 Ø8 L55: z -25.6..29.4, M6 나사부 29.4..39.4
//
// 토크 경로: 벨트 → 풀리 → (상부 플랜지~허브 면압 마찰) → 허브/암
//   풀리 보스 세트스크류가 축을 직접 물어 백업 + 조립 가고정.
// 모든 모듈은 전역 좌표계 배치. 호출은 assembly.scad에서.
// =====================================================

eps = 0.01;

// ---------------------------------------------------
// 1. 스트리퍼 볼트 (쇼울더 Ø8 L55 + M6x10, 머리 하향) — 회전축
// ---------------------------------------------------
module stripper_bolt() {
    tinted(c_axle) {
        difference() {
            union() {
                // 머리 (보스 하면 아래, 와셔 밑)
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
//    회전축 구조: 내륜이 회전(웜), 외륜은 보스에 고정(그레이)
// ---------------------------------------------------
module bearing_608(z0) {
    translate([0, 0, z0]) {
        // 외륜 Ø22..Ø17.8 — 베이스 보스에 압입, 고정
        tinted(c_steel)
            difference() {
                cylinder(d = brg_od, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = 17.8, h = brg_w + 2*eps);
            }
        // 내륜 Ø12.4..Ø8 — 축과 함께 회전
        tinted(c_move_m)
            difference() {
                cylinder(d = 12.4, h = brg_w);
                translate([0, 0, -eps]) cylinder(d = brg_id, h = brg_w + 2*eps);
            }
        // 실드 (외륜 부착, 고정)
        tinted([0.62, 0.64, 0.68])
            translate([0, 0, brg_w/2 - 2])
                difference() {
                    cylinder(d = 17.8, h = 4);
                    translate([0, 0, -eps]) cylinder(d = 12.4, h = 4 + 2*eps);
                }
    }
}

// ---------------------------------------------------
// 3. 내륜 스페이서 8x10x10 (베어링 사이, z -17..-7) — 회전
// ---------------------------------------------------
module inner_spacer() {
    tinted(c_alu)
        translate([0, 0, spacer_z0])
            difference() {
                cylinder(d = skate_od, h = skate_l);
                translate([0, 0, -eps]) cylinder(d = 8.2, h = skate_l + 2*eps);
            }
}

// ---------------------------------------------------
// 4. 평와셔 3종 (모두 회전, 위치별 기성품 규격)
//    머리측·중간 M8×15×1.6 (외경 15 < 외륜 내경 17.8)
//    상부 M6×22×2.0 광폭 — 프린팅 허브 면압 분산
// ---------------------------------------------------
module _flat_washer(z0, t, od, id) {
    tinted(c_washer)
        translate([0, 0, z0])
            difference() {
                cylinder(d = od, h = t);
                translate([0, 0, -eps]) cylinder(d = id, h = t + 2*eps);
            }
}

// 머리측 (보스 하면 아래 z -25.6..-24) — 머리 면압을 하부 내륜에 전달
module head_washer() { _flat_washer(shoulder_z0, head_washer_t, head_washer_od, 8.4); }
// 중간 (상부 내륜~풀리 사이 z 0..1.6) — 풀리 보스 하면이 외륜에 닿지 않게
module mid_washer()  { _flat_washer(brgA_z0 + brg_w, mid_washer_t, mid_washer_od, 8.4); }
// 상부 (허브 위, 너트 밑 z 30.3..32.3) — M6 나사부 구간이라 내경 6.4
module top_washer()  { _flat_washer(top_washer_z0, top_washer_t, top_washer_od, top_washer_id); }

// ---------------------------------------------------
// 5. 암 허브 + 암 (프린팅) — 단순 디스크, 베어링 보어 없음
//    Ø8.3 보어로 쇼울더에 끼워지고 너트 축력으로 풀리 위에 클램프
// ---------------------------------------------------
module arm_hub() {
    tinted(c_move)
        difference() {
            union() {
                // 허브 디스크 (하면이 풀리 상부 플랜지를 누름)
                translate([0, 0, hub_z0])
                    cylinder(d = hub_od, h = hub_h);
                // 암 (+x 방향, 끝으로 갈수록 테이퍼)
                translate([0, 0, arm_z0])
                    linear_extrude(height = arm_z1 - arm_z0)
                        hull() {
                            circle(d = arm_w);
                            translate([arm_len, 0]) circle(d = arm_w_tip);
                        }
            }
            // 축 보어 Ø8.3 (쇼울더 슬라이드 끼움)
            translate([0, 0, hub_z0 - eps])
                cylinder(d = hub_bore, h = hub_h + 2*eps);
            // 암 끝 Ø8 구멍 (다음 관절용)
            translate([arm_len, 0, arm_z0 - eps])
                cylinder(d = 8, h = (arm_z1 - arm_z0) + 2*eps);
            // 경량화 트러스 컷 (관통, 측벽 5mm 이상 유지)
            for (s = arm_slots)
                translate([0, 0, arm_z0 - eps])
                    linear_extrude(height = (arm_z1 - arm_z0) + 2*eps)
                        hull() {
                            translate([s[0] + s[2]/2, 0]) circle(d = s[2]);
                            translate([s[1] - s[2]/2, 0]) circle(d = s[2]);
                        }
        }
}

// ---------------------------------------------------
// 6. GT2 60T 출력 풀리 (8mm bore, 세트스크류 보스 하향)
//    bore가 Ø8 쇼울더에 직접 끼워짐 — 세트스크류가 축을 묾
// ---------------------------------------------------
module pulley60() {
    tinted(c_move_m)
        difference() {
            union() {
                // 세트스크류 보스 (아래 — 베이스 위 1.6, 측면 접근)
                translate([0, 0, p60_z0])
                    cylinder(d = p60_boss_d, h = p60_boss_h);
                // 하부 플랜지
                translate([0, 0, p60_fl1_z0])
                    cylinder(d = p60_flange_d, h = p60_flange_t);
                // 이빨부(원통 단순화)
                translate([0, 0, p60_teeth_z0])
                    cylinder(d = p60_od, h = p60_teeth_h);
                // 상부 플랜지 (허브 하면이 여기를 누름)
                translate([0, 0, p60_fl2_z0])
                    cylinder(d = p60_flange_d, h = p60_flange_t);
            }
            // 보어 Ø8.2
            translate([0, 0, p60_z0 - eps])
                cylinder(d = p60_bore, h = (p60_z1 - p60_z0) + 2*eps);
            // 보스 세트스크류 구멍 (반경 방향 — 축을 직접 묾)
            for (a = p60_screw_angles)
                rotate([0, 0, a])
                    translate([p60_bore/2, 0, p60_screw_z])
                        rotate([0, 90, 0])
                            cylinder(d = 3, h = (p60_boss_d - p60_bore)/2 + eps);
        }
}

// ---------------------------------------------------
// 7. M6 나일록 너트 (적층 상단 z 32.3..38.3 + 캡)
// ---------------------------------------------------
module m6_top_nut() {
    tinted(c_nut) {
        translate([0, 0, nut_z0])
            cylinder($fn = 6, d = nut_m6_af / cos(30), h = nut_m6_h);
        // 나일론 캡 (원통 1mm, 너트 위쪽 끝)
        translate([0, 0, nut_z0 + nut_m6_h])
            cylinder(d = 9, h = 1);
    }
}
