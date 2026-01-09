package com.carefinder.service.kakao;

import com.carefinder.dao.member.MemberKakaoDAO;
import com.carefinder.dto.member.MemberKakaoDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MemberKakaoServiceImpl implements MemberKakaoService {

    private static final String SOCIAL_PASSWORD = "SOCIAL_LOGIN";

    private final MemberKakaoDAO memberDAO;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public MemberKakaoDTO kakaoLogin(Map<String, Object> kakaoUser) {

        String kakaoId = String.valueOf(kakaoUser.get("kakaoId"));

        MemberKakaoDTO member = memberDAO.findByKakaoId(kakaoId);

        if (member == null) {
            member = new MemberKakaoDTO();
            member.setKakaoId(kakaoId);
            member.setName((String) kakaoUser.get("nickname"));
            member.setEmail((String) kakaoUser.get("email"));
            member.setGender((String) kakaoUser.get("gender"));
            //생년월일 데이터
            String pnum = calculatePhoneNumber((String) kakaoUser.get("phoneNumber"));
            member.setPhonenumber(pnum);



            String birthYear = (String) kakaoUser.get("birthyear");
            String birthDay = (String) kakaoUser.get("birthday");
            String birth = birthYear + birthDay; // 예: "20001108"
            member.setBirth(birth);

            System.out.println(birthYear);
            System.out.println(birthDay);
            System.out.println(birth);
            System.out.println(calculateAge(birth));

            // 나이 계산
            member.setAge(calculateAge(birth));

            // 카카오 ID로 ID 자동 생성
            member.setId("kakao_" + kakaoId);

            // 임시 비밀번호 설정
            member.setPw(
                    passwordEncoder.encode(SOCIAL_PASSWORD)
            );

            memberDAO.insertKakaoMember(member);
            member = memberDAO.findByKakaoId(kakaoId);
        }

        return member;
    }

    @Override
    public MemberKakaoDTO login(String id, String pw) {
        MemberKakaoDTO member = memberDAO.findById(id);
        if (member == null) return null;

        if (!passwordEncoder.matches(pw, member.getPw())) {
            return null;
        }

        return member;
    }

    @Override
    public void join(MemberKakaoDTO member) {
        memberDAO.insertMember(member);
    }

    // 나이 계산 20001108 일경우
    public int calculateAge(String birth) {
        int year = Integer.parseInt(birth.substring(0, 4));
        int month = Integer.parseInt(birth.substring(4, 6));
        int day = Integer.parseInt(birth.substring(6, 8));

        LocalDate birthDate = LocalDate.of(year, month, day);
        LocalDate today = LocalDate.now();

        return Period.between(birthDate, today).getYears();
    }
    //핸드폰 번호 형식 변환 +82 10-6803-2060 일 경우
    public String calculatePhoneNumber(String p){
        String [] arr = p.split(" ");
        arr[0] = "0";
        p = arr[0] + arr[1];
        return p;
    }

}
