package com.carefinder.service.google;

import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleTokenResponseDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;

public interface GoogleService {

    GoogleTokenResponseDTO getAccessToken(String code);

    GoogleUserInfoDTO getUserInfo(String accessToken);

    // People API 분리 메서드
    GooglePeopleDTO getPeopleInfo(String accessToken);
}
