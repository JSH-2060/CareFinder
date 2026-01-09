package com.carefinder.service.bmi;

import com.carefinder.dao.bmi.BmiCriteriaDAO;
import com.carefinder.dao.bmi.BmiDAO;
import com.carefinder.dao.bmi.ChildBmiPercentileDAO;
import com.carefinder.dto.bmi.BmiCriteriaDTO;
import com.carefinder.dto.bmi.BmiDTO;
import com.carefinder.dto.bmi.ChildBmiPercentileDTO;
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
    private final BmiCriteriaDAO bmiCriteriaDAO;
    private final ChildBmiPercentileDAO childBmiPercentileDAO;

    /* ==================================================
       만나이(개월) 계산
    ================================================== */
    private int calculateAgeMonth(LocalDate birthDate, LocalDate 기준일) {
        Period p = Period.between(birthDate, 기준일);
        return p.getYears() * 12 + p.getMonths();
    }

    /* ==================================================
       BMI 계산 + 판정 (공통 로직)
    ================================================== */
    private void calculateAndJudge(BmiDTO dto, LocalDate 기준일) {

        // ===== 필수값 체크 =====
        if (dto.getBirthDate() == null || dto.getGender() == null) {
            dto.setResult("기준 없음");
            return;
        }

        if (dto.getHeight() == null || dto.getWeight() == null) {
            dto.setResult("입력 오류");
            return;
        }

        // ===== 키 / 몸무게 범위 =====
        if (dto.getHeight() < 80 || dto.getWeight() < 9 || dto.getWeight() >= 150) {
            dto.setResult("입력 범위 오류");
            return;
        }

        // ===== 나이 계산 =====
        int ageMonth = calculateAgeMonth(dto.getBirthDate(), 기준일);

        if (ageMonth < 24 || ageMonth > 1440) {
            dto.setResult("계산 불가");
            return;
        }

        dto.setAgeMonth(ageMonth);

        // ===== BMI 계산 =====
        double heightM = dto.getHeight() / 100.0;
        double bmi = dto.getWeight() / (heightM * heightM);
        bmi = Math.round(bmi * 100) / 100.0;
        dto.setBmiValue(bmi);

        // ===== 판정 =====
        String result;

        if (ageMonth < 228) {
            // 소아
            ChildBmiPercentileDTO c =
                    childBmiPercentileDAO.findByGenderAndAgeMonth(
                            dto.getGender(), ageMonth
                    );

            if (c == null) {
                result = "기준 없음";
            } else if (bmi < c.getP5()) result = "저체중";
            else if (bmi < c.getP85()) result = "정상";
            else if (bmi < c.getP95()) result = "과체중";
            else result = "비만";

        } else {
            // 성인
            int ageYear = ageMonth / 12;

            BmiCriteriaDTO c =
                    bmiCriteriaDAO.findByGenderAndAge(
                            dto.getGender(), ageYear
                    );

            if (c == null) {
                result = "기준 없음";
            } else {
                result = calculateAdultResult(bmi, c);
            }
        }

        dto.setResult(result);
    }

    /* ==================================================
       BMI 계산 + 저장
    ================================================== */
    public void calculateAndSave(BmiDTO dto, Long mno) {

        dto.setMno(mno);

        calculateAndJudge(dto, LocalDate.now());

        bmiDAO.insert(dto);
    }

    /* ==================================================
       자녀 기준 BMI 리스트
    ================================================== */
    public List<BmiDTO> getBmiListByChild(Long mno, Integer childId) {

        List<BmiDTO> list = bmiDAO.findByChild(mno, childId);
        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            calculateAndJudge(dto, dto.getRecordDate().toLocalDate());
        }

        return list;
    }

    /* ==================================================
       날짜 조건 + 자녀 기준
    ================================================== */
    public List<BmiDTO> getBmiListByDate(
            Long mno, Integer childId, String startDate, String endDate) {

        List<BmiDTO> list =
                bmiDAO.findByDateRangeAndChild(mno, childId, startDate, endDate);

        if (list == null) return new ArrayList<>();

        for (BmiDTO dto : list) {
            calculateAndJudge(dto, dto.getRecordDate().toLocalDate());
        }

        return list;
    }

    /* ==================================================
       수정 (키 / 몸무게만)
    ================================================== */
    public void updateBmi(BmiDTO dto) {

        BmiDTO origin = bmiDAO.findById(dto.getBmiNo());
        if (origin == null) return;

        dto.setChildId(origin.getChildId());
        dto.setMno(origin.getMno());
        dto.setBirthDate(origin.getBirthDate());
        dto.setGender(origin.getGender());
        dto.setRecordDate(origin.getRecordDate());

        calculateAndJudge(dto, origin.getRecordDate().toLocalDate());

        bmiDAO.update(dto);
    }

    /* ==================================================
       삭제
    ================================================== */
    public void deleteBmi(Long bmiNo) {
        bmiDAO.deleteByBmiNo(bmiNo);
    }

    /* ==================================================
       성인 BMI 판정
    ================================================== */
    private String calculateAdultResult(double bmi, BmiCriteriaDTO c) {
        if (bmi < c.getUnderBmi()) return "저체중";
        else if (bmi < c.getNormalBmi()) return "정상";
        else if (bmi < c.getObeseBmi()) return "과체중";
        else if (bmi < c.getSevereBmi()) return "비만";
        else return "고도비만";
    }
    public BmiDTO getBmiById(Long bmiNo) {
        return bmiDAO.findById(bmiNo);
    }
}
