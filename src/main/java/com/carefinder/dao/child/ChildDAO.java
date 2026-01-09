package com.carefinder.dao.child;

import com.carefinder.dto.child.ChildDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ChildDAO {
    void insert(ChildDTO dto);
    List<ChildDTO> getChildList(Long mno);

    // ★ [추가된 부분]
    ChildDTO selectOne(Integer childId);  // 수정폼용 단건 조회
    void update(ChildDTO dto);            // 수정 실행
    void delete(Integer childId);         // 삭제 실행
}