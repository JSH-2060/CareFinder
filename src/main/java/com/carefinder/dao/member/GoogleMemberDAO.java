package com.carefinder.dao.member;

import com.carefinder.dto.member.GoogleMemberDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface GoogleMemberDAO {

    GoogleMemberDTO findByGoogleId(String googleId);

    GoogleMemberDTO findByEmail(String email);

    void updateGoogleIdByEmail(String googleId, String email);

    void insertGoogleMember(GoogleMemberDTO member);

    void updateExtraInfo(GoogleMemberDTO member);
}
