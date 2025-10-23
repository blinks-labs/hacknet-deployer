package main

import (
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"hash/crc64"
	"io"
	"os"
        "flag"
	"github.com/libp2p/go-libp2p/core/peer"
)


type IdentityInfo struct {
	Key []byte
	ID  peer.ID // this is needed only to simplify integration with some testing tools
}

// loadFromFile loads the data from the given file and verifies the checksum. It returns the data without the checksum
func loadFromFile(path string) (data []byte, err error) {
	if _, err = os.Stat(path); os.IsNotExist(err) {
		return nil, os.ErrNotExist
	}
	r, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("error opening file: %w", err)
	}
	defer r.Close()

	data, err = io.ReadAll(r)
	if err != nil {
		return nil, fmt.Errorf("error reading file: %w", err)
	}

	if len(data) < 8 {
		return nil, errors.New("file is too short")
	}
	fileCrc := binary.LittleEndian.Uint64(data[:8])
	dataCrc := crc64.Checksum(data[8:], crc64.MakeTable(crc64.ISO))
	if fileCrc != dataCrc {
		return nil, fmt.Errorf("checksum mismatch: %x != %x", fileCrc, dataCrc)
	}
	return data[8:], nil
}

func main() {
	// Define the flag with a default value and usage description
	keyfile := flag.String("keyfile", "keyfile", "key file path")
	
	// Parse the flags
	flag.Parse()

	data, err := loadFromFile(*keyfile)
	if err != nil {
		fmt.Errorf("read file %s: %w", *keyfile, err)
	}

	var info IdentityInfo
	err = json.Unmarshal(data, &info)
	if err != nil {
	   fmt.Errorf("unmarshal file content from %s into %+v: %w", *keyfile, info, err)
	}

	fmt.Println(info.ID.String())
}
