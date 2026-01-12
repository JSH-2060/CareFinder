package com.carefinder.service.bmi;

import com.carefinder.dao.bmi.BmiCriteriaDAO;
import com.carefinder.dao.bmi.BmiDAO;
import com.carefinder.dao.bmi.ChildBmiPercentileDAO;
import com.carefinder.dao.child.ChildDAO;
import com.carefinder.dao.member.MemberProfileDAO;
import com.carefinder.dto.bmi.BmiCriteriaDTO;
import com.carefinder.dto.bmi.BmiDTO;
import com.carefinder.dto.bmi.ChildBmiPercentileDTO;
import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.member.MemberProfileDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BmiService {

    private final BmiDAO bmiDAO;
    private final ChildDAO childDAO;
    private final MemberProfileDAO memberProfileDAO;
    private final BmiCriteriaDAO bmiCriteriaDAO;
    private final ChildBmiPercentileDAO childBmiPercentileDAO;

    /* ==================================================
       만나이(개월) 계산
    ================================================== */
    private int calculateAgeMonth(LocalDate birth, LocalDate 기준일) {
        Period p = Period.between(birth, 기준일);
        return p.getYears() * 12 + p.getMonths();
    }

    /* ==================================================
       👤 부모 / 👶 자녀 birth & gender 채우기
    ================================================== */
    private boolean fillPersonInfo(BmiDTO dto) {

        // 이미 있으면 OK
        if (dto.getBirthDate() != null && dto.getGender() != null) {
            return true;
        }

        // 👶 자녀
        if (dto.getChildId() != null && dto.getChildId() != 0) {
            ChildDTO child = childDAO.selectOne(dto.getChildId());
            if (child == null) return false;

            dto.setBirthDate(LocalDate.parse(child.getBirth()));
            dto.setGender(child.getGender());
            return true;
        }

        // 👤 부모(나)
        MemberProfileDTO profile =
                memberProfileDAO.findByMno(dto.getMno());

        if (profile == null ||
                profile.getBirth() == null ||
                profile.getGender() == null) {
            return false;
        }

        dto.setBirthDate(profile.getBirth());

        // 🔥 gender 정규화 (이게 핵심)
        String g = profile.getGender().toLowerCase();
        if (g.equals("male")) {
            dto.setGender("M");
        } else if (g.equals("female")) {
            dto.setGender("F");
        } else {
            dto.setGender(profile.getGender());
        }

        return true;
    }

    /* ==================================================
       BMI 계산 + 판정 + 기준바 퍼센트
    ================================================== */
    private boolean calculate(BmiDTO dto, LocalDate 기준일) {

        if (!fillPersonInfo(dto)) return false;
        if (dto.getHeight() == null || dto.getWeight() == null) return false;

        // 키 / 몸무게 범위
        if (dto.getHeight() < 80) return false;
        if (dto.getWeight() < 9 || dto.getWeight() >= 150) return false;

        int ageMonth = calculateAgeMonth(dto.getBirthDate(), 기준일);
        dto.setAgeMonth(ageMonth);

        boolean adult = ageMonth >= 228; // 19세 이상
        dto.setAdult(adult);

        // BMI 계산
        double h = dto.getHeight() / 100.0;
        double bmi = dto.getWeight() / (h * h);
        bmi = Math.round(bmi * 100) / 100.0;
        dto.setBmiValue(bmi);

        String result;
        double percent;

        /* ==========================
           👶 소아 · 청소년
        ========================== */
        if (!adult) {

            ChildBmiPercentileDTO c =
                    childBmiPercentileDAO
                            .findByGenderAndAgeMonth(dto.getGender(), ageMonth);

            if (c == null) return false;

            dto.setCut1(c.getP5());
            dto.setCut2(c.getP85());
            dto.setCut3(c.getP95());
            dto.setCut4(null);

            if (bmi < c.getP5()) {
                result = "저체중";
                percent = 10;
            } else if (bmi < c.getP85()) {
                result = "정상";
                percent = 30;
            } else if (bmi < c.getP95()) {
                result = "과체중";
                percent = 60;
            } else {
                result = "비만";
                percent = 85;
            }
        }

        /* ==========================
           🧑 성인
        ========================== */
        else {

            int ageYear = ageMonth / 12;

            BmiCriteriaDTO c =
                    bmiCriteriaDAO
                            .findByGenderAndAge(dto.getGender(), ageYear);

            if (c == null) return false;

            dto.setCut1(c.getUnderBmi());
            dto.setCut2(c.getNormalBmi());
            dto.setCut3(c.getObeseBmi());
            dto.setCut4(c.getSevereBmi());

            if (bmi < c.getUnderBmi()) {
                result = "저체중";
                percent = 10;
            } else if (bmi < c.getNormalBmi()) {
                result = "정상";
                percent = 30;
            } else if (bmi < c.getObeseBmi()) {
                result = "과체중";
                percent = 60;
            } else if (bmi < c.getSevereBmi()) {
                result = "비만";
                percent = 80;
            } else {
                result = "고도비만";
                percent = 95;
            }
        }

        dto.setResult(result);
        dto.setBmiPercent(percent);
        return true;
    }

    /* ==================================================
       BMI 계산 + 저장
    ================================================== */
    public BmiDTO calculateAndSave(BmiDTO dto, Long mno) {

        dto.setMno(mno);

        // ✅ 반드시 필요 (KST 기준)
        dto.setRecordDate(
                java.time.LocalDateTime.now(
                        java.time.ZoneId.of("Asia/Seoul")
                )
        );

        boolean ok = calculate(dto, dto.getRecordDate().toLocalDate());
        if (!ok) return dto;

        bmiDAO.insert(dto);
        return dto;
    }

    /* ==================================================
       자녀 / 부모 BMI 리스트
    ================================================== */
    public List<BmiDTO> getBmiListByChild(Long mno, Integer childId) {
        List<BmiDTO> list = bmiDAO.findByChild(mno, childId);
        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            if (dto.getRecordDate() != null) {
                calculate(dto, dto.getRecordDate().toLocalDate());
            }
        }
        return list;
    }

    /* ==================================================
       날짜 조건
    ================================================== */
    public List<BmiDTO> getBmiListByDate(
            Long mno, Integer childId, String startDate, String endDate) {

        List<BmiDTO> list =
                bmiDAO.findByDateRangeAndChild(mno, childId, startDate, endDate);

        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            if (dto.getRecordDate() != null) {
                calculate(dto, dto.getRecordDate().toLocalDate());
            }
        }
        return list;
    }

    /* ==================================================
       최근 BMI (기준바용)
    ================================================== */
    public BmiDTO getLatestBmi(Long mno, Integer childId) {

        BmiDTO dto;

        // 🔥 부모(나)
        if (childId == null || childId == 0) {
            dto = bmiDAO.findLatestByParent(mno);
        }
        // 👶 자녀
        else {
            dto = bmiDAO.findLatestByChildId(childId);
        }

        if (dto == null) return null;

        if (dto.getRecordDate() != null) {
            calculate(dto, dto.getRecordDate().toLocalDate());
        }
        return dto;
    }

    /* ==================================================
       수정
    ================================================== */
    public void updateBmi(BmiDTO dto) {

        BmiDTO origin = bmiDAO.findById(dto.getBmiNo());
        if (origin == null) return;

        dto.setChildId(origin.getChildId());
        dto.setMno(origin.getMno());
        dto.setBirthDate(origin.getBirthDate());
        dto.setGender(origin.getGender());
        dto.setRecordDate(origin.getRecordDate());

        if (!calculate(dto, origin.getRecordDate().toLocalDate())) return;
        bmiDAO.update(dto);
    }

    /* ==================================================
       삭제
    ================================================== */
    public void deleteBmi(Long bmiNo) {
        bmiDAO.deleteByBmiNo(bmiNo);
    }

    /* ==================================================
       자녀 목록
    ================================================== */
    public List<ChildDTO> getChildList(Long mno) {
        return bmiDAO.selectChildList(mno);
    }

    /* ==================================================
   단건 조회 (수정 팝업용)
================================================== */
    public BmiDTO getBmiById(Long bmiNo) {

        BmiDTO dto = bmiDAO.findById(bmiNo);
        if (dto == null) return null;

        // 🔥 부모면 childId = 0 보정
        if (dto.getChildId() == null) {
            dto.setChildId(0);
        }

        // 🔥 계산 다시 (기준바/판정용)
        if (dto.getRecordDate() != null) {
            calculate(dto, dto.getRecordDate().toLocalDate());
        }

        return dto;
    }

}
